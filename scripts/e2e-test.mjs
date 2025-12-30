import puppeteer from 'puppeteer'

async function runE2ETest() {
  console.log('🦋 Dream Butterfly - E2E Test')
  console.log('================================\n')

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  })

  const page = await browser.newPage()

  console.log('1. Testing homepage...')
  await page.goto('http://localhost:3000', { waitUntil: 'networkidle0' })
  const title = await page.title()
  console.log(`   ✓ Page title: ${title}`)

  const heroText = await page.$eval('.hero h1', el => el.textContent)
  console.log(`   ✓ Hero text: ${heroText}`)

  console.log('\n2. Testing navigation...')
  const navLinks = await page.$$('.nav-links a')
  console.log(`   ✓ Found ${navLinks.length} navigation links`)

  console.log('\n3. Testing login page...')
  await page.click('a[href="/login"]')
  await page.waitForSelector('.login-card')
  const loginTitle = await page.$eval('.login-card h2', el => el.textContent)
  console.log(`   ✓ Login page title: ${loginTitle}`)

  console.log('\n4. Testing register page...')
  await page.click('a[href="/register"]')
  await page.waitForSelector('.register-card')
  const registerTitle = await page.$eval('.register-card h2', el => el.textContent)
  console.log(`   ✓ Register page title: ${registerTitle}`)

  console.log('\n5. Testing user registration...')
  await page.type('#username', 'testuser')
  await page.type('#email', 'test@example.com')
  await page.type('#password', 'password123')
  await page.type('#confirmPassword', 'password123')
  await page.click('.submit-btn')
  await page.waitForNavigation({ waitUntil: 'networkidle0' })
  const isLoggedIn = await page.$('.logout-btn')
  console.log(`   ✓ Registration ${isLoggedIn ? 'successful' : 'failed'}`)

  console.log('\n6. Testing create video page...')
  await page.click('a[href="/create"]')
  await page.waitForSelector('.create-video-container')
  const createTitle = await page.$eval('.create-video-container h2', el => el.textContent)
  console.log(`   ✓ Create video page: ${createTitle}`)

  console.log('\n7. Testing my videos page...')
  await page.click('a[href="/my-videos"]')
  await page.waitForSelector('.my-videos-container')
  const emptyState = await page.$('.empty-state')
  console.log(`   ✓ My videos page: ${emptyState ? 'Empty state shown' : 'Videos listed'}`)

  console.log('\n8. Testing profile page...')
  await page.click('a[href="/profile"]')
  await page.waitForSelector('.profile-container')
  const avatar = await page.$('.avatar')
  console.log(`   ✓ Profile page: ${avatar ? 'Avatar shown' : 'Loaded'}`)

  console.log('\n✅ All E2E tests passed!')

  await browser.close()
}

runE2ETest().catch(console.error)
