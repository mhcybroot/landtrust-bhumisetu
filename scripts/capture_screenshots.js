const puppeteer = require('puppeteer-core');
const fs = require('fs');
const path = require('path');

const CHROMIUM_PATH = '/usr/bin/chromium';
const BASE_URL = 'http://localhost:8086';

const PHONE_DIR = path.join(__dirname, '../assets/playstore/screenshots/phone');
const TABLET_DIR = path.join(__dirname, '../assets/playstore/screenshots/tablet');
const ARTIFACT_DIR = '/home/mhcybroot/.gemini/antigravity/brain/cb08b1dc-a41c-42c4-bd28-4b13b48598be';

async function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function capture() {
  console.log('🚀 Launching Chromium for Google Play Store Screenshots...');
  const browser = await puppeteer.launch({
    executablePath: CHROMIUM_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-gpu']
  });

  // ==========================================
  // 1. Phone Screenshots (1080 x 2400)
  // ==========================================
  console.log('\n📸 Capturing Mobile Screenshots (1080x2400)...');
  const page = await browser.newPage();
  const width = 450;
  const height = 1000;
  await page.setViewport({ width, height, deviceScaleFactor: 2.4 }); // 450 * 2.4 = 1080, 1000 * 2.4 = 2400

  await page.goto(BASE_URL, { waitUntil: 'networkidle2' });
  await sleep(4000); // Wait for Flutter Canvas to settle

  // 1. Home Marketplace
  console.log('Capturing: 01_home_marketplace.png');
  const p1 = path.join(PHONE_DIR, '01_home_marketplace.png');
  await page.screenshot({ path: p1 });

  // 2. Tab 1: Buyer Demands
  console.log('Capturing: 02_buyer_demands.png');
  await page.mouse.click(width * 0.375, height - 30);
  await sleep(1500);
  const p2 = path.join(PHONE_DIR, '02_buyer_demands.png');
  await page.screenshot({ path: p2 });

  // 3. Tab 2: Rules & Safety Warning
  console.log('Capturing: 03_rules_and_safety.png');
  await page.mouse.click(width * 0.625, height - 30);
  await sleep(1500);
  const p3 = path.join(PHONE_DIR, '03_rules_and_safety.png');
  await page.screenshot({ path: p3 });

  // 4. Tab 3: Login & 1-Click Access
  console.log('Capturing: 04_login_and_auth.png');
  await page.mouse.click(width * 0.875, height - 30);
  await sleep(1500);
  const p4 = path.join(PHONE_DIR, '04_login_and_auth.png');
  await page.screenshot({ path: p4 });

  // 5. Click Admin Demo Login
  console.log('Capturing: 05_admin_management_panel.png');
  // Admin button is the first button in the demo accounts wrap: around x=100, y=280
  await page.mouse.click(100, 280);
  await sleep(3000);
  const p5 = path.join(PHONE_DIR, '05_admin_management_panel.png');
  await page.screenshot({ path: p5 });

  // 6. Switch back to Home (Explore) while logged in to see verified listing
  console.log('Capturing: 06_verified_properties_feed.png');
  await page.mouse.click(width * 0.125, height - 30);
  await sleep(2000);
  const p6 = path.join(PHONE_DIR, '06_verified_properties_feed.png');
  await page.screenshot({ path: p6 });

  await page.close();

  // ==========================================
  // 2. Tablet Screenshots (1600 x 2560 & 1200 x 1920)
  // ==========================================
  console.log('\n📸 Capturing Tablet Screenshots...');
  
  // 7-inch Tablet (1200 x 1920)
  const tab7 = await browser.newPage();
  await tab7.setViewport({ width: 600, height: 960, deviceScaleFactor: 2.0 }); // 600*2=1200, 960*2=1920
  await tab7.goto(BASE_URL, { waitUntil: 'networkidle2' });
  await sleep(3500);
  const t1 = path.join(TABLET_DIR, '01_tablet_7inch_home.png');
  await tab7.screenshot({ path: t1 });
  await tab7.close();

  // 10-inch Tablet (1600 x 2560)
  const tab10 = await browser.newPage();
  await tab10.setViewport({ width: 800, height: 1280, deviceScaleFactor: 2.0 }); // 800*2=1600, 1280*2=2560
  await tab10.goto(BASE_URL, { waitUntil: 'networkidle2' });
  await sleep(3500);
  const t2 = path.join(TABLET_DIR, '02_tablet_10inch_home.png');
  await tab10.screenshot({ path: t2 });
  
  // 10-inch Rules & Safety
  await tab10.mouse.click(320, 35); // Navigation tab on desktop/tablet header
  await sleep(1500);
  const t3 = path.join(TABLET_DIR, '03_tablet_10inch_rules.png');
  await tab10.screenshot({ path: t3 });
  await tab10.close();

  await browser.close();

  // Copy files to artifact directory for markdown display
  console.log('\n📋 Copying screenshots to artifacts directory...');
  const phoneFiles = fs.readdirSync(PHONE_DIR).filter(f => f.endsWith('.png'));
  for (const f of phoneFiles) {
    fs.copyFileSync(path.join(PHONE_DIR, f), path.join(ARTIFACT_DIR, f));
  }
  const tabletFiles = fs.readdirSync(TABLET_DIR).filter(f => f.endsWith('.png'));
  for (const f of tabletFiles) {
    fs.copyFileSync(path.join(TABLET_DIR, f), path.join(ARTIFACT_DIR, f));
  }

  console.log('✅ All screenshots captured and saved successfully!');
}

capture().catch(err => {
  console.error('❌ Error during capture:', err);
  process.exit(1);
});
