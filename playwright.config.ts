import { defineConfig, devices } from '@playwright/test';
import { randomBytes } from 'node:crypto';

// Random QA-only accounts; never reuse an operational administrator credential.
process.env.E2E_ADMIN_PASSWORD ??= randomBytes(24).toString('base64url');
process.env.E2E_DRIVER_PASSWORD ??= randomBytes(24).toString('base64url');
process.env.E2E_SECRET_KEY ??= randomBytes(48).toString('hex');
process.env.E2E_SCHEMA ??= `e2e_${Date.now()}_${randomBytes(4).toString('hex')}`;
process.env.E2E_API_URL ??= 'http://127.0.0.1:8010/api/v1';
process.env.E2E_WEB_URL ??= 'http://127.0.0.1:8095';
const reportName = process.env.E2E_REPORT_SET === 'visual' ? 'playwright-visual' : 'playwright';

export default defineConfig({
  testDir: './tests/e2e',
  testMatch: process.env.E2E_REPORT_SET === 'visual' ? '**/gold.spec.ts' : '**/*.spec.ts',
  timeout: 120_000,
  expect: { timeout: 25_000 },
  fullyParallel: false,
  workers: 1,
  retries: 0,
  forbidOnly: !!process.env.CI,
  outputDir: `reports/${reportName}-results`,
  reporter: [
    ['list'],
    ['html', { outputFolder: `reports/${reportName}-html`, open: 'never' }],
    ['json', { outputFile: `reports/${reportName}-results.json` }],
    ['junit', { outputFile: `reports/${reportName}-junit.xml` }],
  ],
  use: {
    actionTimeout: 20_000,
    navigationTimeout: 60_000,
    baseURL: process.env.E2E_WEB_URL,
    viewport: { width: 1440, height: 1000 },
    locale: 'es-PE',
    timezoneId: 'America/Lima',
    screenshot: 'only-on-failure',
    // Raw browser traces/HAR can expose login payloads and authorization headers.
    // The fixture records a sanitized network trace with no bodies or headers.
    trace: 'off',
    video: 'off',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: `"${process.env.E2E_PYTHON || 'python'}" tools/e2e/serve.py`,
    url: `${process.env.E2E_WEB_URL}/healthz`,
    timeout: 120_000,
    reuseExistingServer: false,
    stdout: 'ignore',
    stderr: 'pipe',
    gracefulShutdown: { signal: 'SIGTERM', timeout: 5000 },
  },
});
