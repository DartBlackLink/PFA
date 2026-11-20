import { defineConfig, devices } from '@playwright/test';

// Browser regression of the activation handshake; no API, database or accounts.
export default defineConfig({
  testDir: './tests/browser',
  timeout: 30_000,
  retries: 0,
  forbidOnly: !!process.env.CI,
  workers: 1,
  outputDir: 'reports/semantics-results',
  reporter: [
    ['list'],
    ['json', { outputFile: 'reports/semantics-results.json' }],
    ['junit', { outputFile: 'reports/semantics-junit.xml' }],
  ],
  use: { trace: 'off', video: 'off', screenshot: 'only-on-failure' },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
  ],
});
