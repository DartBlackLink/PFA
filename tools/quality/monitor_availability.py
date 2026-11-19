"""Bounded health checks; measured sample availability is not monthly uptime."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
from time import perf_counter, sleep
from urllib.error import HTTPError
from urllib.parse import urlsplit
from urllib.request import urlopen


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('urls',nargs='+')
    parser.add_argument('--count',type=int,default=6)
    parser.add_argument('--interval',type=float,default=2)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    if not 1<=args.count<=60 or not .5<=args.interval<=60:parser.error('Límites: 1–60 muestras e intervalo 0,5–60 s')
    for url in args.urls:
        parsed=urlsplit(url)
        if parsed.username or parsed.password or parsed.query or parsed.fragment or not parsed.hostname:
            parser.error('URL sin credenciales ni parámetros')
        if parsed.scheme!='https' and not(parsed.scheme=='http' and parsed.hostname in {'localhost','127.0.0.1'}):
            parser.error('HTTPS público o HTTP de loopback')
    rows=[];started=datetime.now(timezone.utc).isoformat()
    for number in range(args.count):
        for url in args.urls:
            before=perf_counter();row={'url':url,'sample':number+1,'at':datetime.now(timezone.utc).isoformat()}
            try:
                with urlopen(url,timeout=5) as response:
                    body=response.read(4096)
                    row['status']=response.status
                    if urlsplit(url).path.endswith('/api/v1/health'):
                        row['contract_ok']=json.loads(body).get('status')=='ok'
                    else:row['contract_ok']=body.strip().lower() in {b'ok',b'healthy'}
                    row['ok']=response.status==200 and row['contract_ok']
            except (OSError,ValueError,HTTPError) as error:
                row.update(ok=False,error=type(error).__name__)
            row['milliseconds']=round((perf_counter()-before)*1000,3);rows.append(row)
        if number+1<args.count:sleep(args.interval)
    success=sum(row['ok'] for row in rows)
    result={'started':started,'finished':datetime.now(timezone.utc).isoformat(),
            'successful':success,'total':len(rows),'sample_availability_percent':100*success/len(rows),
            'scope':'Specified health endpoints during this observation window only; not production/monthly uptime or complete business-flow availability.',
            'records':rows}
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(result,indent=2),encoding='utf-8')
    print(f'Health observations: {success}/{len(rows)}')
    return success!=len(rows)


if __name__=='__main__':raise SystemExit(main())
