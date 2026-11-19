"""Algebraic unit cases, not participant responses or study results."""
import csv
from decimal import Decimal
from pathlib import Path
import tempfile
import unittest
from score_sus import calculate, grade, HEADERS, read_responses, report
from merge_sus import merge


class SusCalculationTests(unittest.TestCase):
    def test_extremes_and_polarity(self):
        self.assertEqual(calculate([5, 1]*5)[2], Decimal('100'))
        self.assertEqual(calculate([1, 5]*5)[2], Decimal('0'))
        self.assertEqual(calculate([3]*10)[2], Decimal('50'))

    def test_rejects_missing_out_of_range_and_noninteger(self):
        for case in ([1]*9, [0]*10, [6]*10, [2.0]*10, [True]*10):
            with self.assertRaises(ValueError): calculate(case)

    def test_grade_boundaries(self):
        for value, expected in [('0','F'),('51.7','D'),('62.7','C−'),('68','C'),('72.6','B−'),('84.1','A+')]:
            self.assertEqual(grade(Decimal(value)), expected)

    def temporary_csv(self, rows):
        folder = tempfile.TemporaryDirectory(); self.addCleanup(folder.cleanup)
        path = Path(folder.name)/'unit-fixture.csv'
        with path.open('w',encoding='utf-8',newline='') as stream:
            writer=csv.writer(stream); writer.writerow(HEADERS); writer.writerows(rows)
        return path

    def row(self, code='SUS-ABCDEF123456'):
        return [code,'ADMIN','PC','2026-11-18','SI',*([3]*10)]

    def test_empty_does_not_create_zero_score(self):
        result=report(self.temporary_csv([]))
        self.assertEqual(result['n'],0)
        self.assertIsNone(result['media_exacta'])
        self.assertIsNone(result['grado'])

    def test_incomplete_sample_is_explicit(self):
        result=report(self.temporary_csv([self.row()]))
        self.assertEqual(result['estado'],'MUESTRA_INSUFICIENTE')
        self.assertIsNone(result['media_exacta'])

    def test_duplicate_is_rejected(self):
        with self.assertRaises(ValueError): read_responses(self.temporary_csv([self.row(),self.row()]))

    def test_without_consent_is_rejected(self):
        row=self.row();row[4]='NO'
        with self.assertRaises(ValueError): read_responses(self.temporary_csv([row]))

    def test_valid_five_rows_produce_exact_mean(self):
        rows=[self.row(f'SUS-{i:012X}') for i in range(5)]
        result=report(self.temporary_csv(rows))
        self.assertEqual(result['media_exacta'],'50.0')
        self.assertEqual(result['grado'],'F')

    def test_merge_rejects_duplicate_across_files_without_partial_output(self):
        first=self.temporary_csv([self.row()])
        second=self.temporary_csv([self.row()])
        target=first.parent/'unidas.csv'
        with self.assertRaises(ValueError): merge([first,second],target)
        self.assertFalse(target.exists())

    def test_merge_preserves_original_and_refuses_overwrite(self):
        first=self.temporary_csv([self.row()])
        second=self.temporary_csv([self.row('SUS-ABCDEF123457')])
        before=first.read_bytes()
        target=first.parent/'unidas.csv'
        self.assertEqual(merge([first,second],target),2)
        self.assertEqual(len(read_responses(target)),2)
        self.assertEqual(first.read_bytes(),before)
        with self.assertRaises(ValueError): merge([second],target)


if __name__=='__main__': unittest.main()
