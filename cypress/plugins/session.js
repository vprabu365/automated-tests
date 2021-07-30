const { chromium } = require('playwright');

async function launchChromium() {
    return await chromium.launch({
        headless: false,
        args: [
            '--no-sandbox',
			'--disable-setuid-sandbox',
			'--disable-dev-shm-usage',
			'--ignore-certificate-errors',
			'--unsafely-treat-insecure-origin-as-secure=https://localhost:4200/',
			'--disable-notifications'
        ]
    })
}

/*
async function login({ page, options } = {}) {
  await page.waitForSelector(options.loginSelector);
  await page.click(options.loginSelector);
  await page.waitForSelector(".valet-masthead__signin-link-label");
  await page.click(".valet-masthead__signin-link-label");
}

async function typeUsername({ page, options } = {}) {
  await page.waitForSelector('input[type="email"]');
  await page.type('input[type="email"]', options.username);
  const found = (await page.content()).includes("One account. All of Google.");
  const nextButton = found ? "#next" : "#identifierNext";
  await page.click(nextButton);
}

async function typePassword({ page, options } = {}) {
  await page.waitForSelector('input[type="password"]', { visible: true });
  await page.type('input[type="password"]', options.password);
  const found = (await page.content()).includes("One account. All of Google.");
  const signInButton = found ? "#signIn" : "#passwordNext";
  await page.waitForSelector(signInButton, { visible: true });
  await page.click(signInButton);
}
* */

async function googleLogin (page, username, password) {
    if (!username || !password) {
		throw new Error('Username or Password missing for login');
	}
    await page.waitForSelector(`[data-qa='googleButton']`);
    await page.click(`[data-qa='googleButton']`);
    await page.waitForNavigation();
   // await page.waitForSelector("[id='integrationTest_valetHeader']")
    await page.waitForSelector(".valet-masthead__signin-link-label");
    await page.click(".valet-masthead__signin-link-label");

	await page.fill(`input[type="email"]`, username);
    const nextButton = "#identifierNext";
    await page.click(nextButton);
   // await page.waitForNavigation()
  //await page.waitForSelector("div[id='password']")
  await page.pause(5000)
	await page.fill(`input[type="password"]`, password);
	 await page.click(`#passwordNext`);
  //await page.waitForNavigation()
  await page.pause(5000)
  //await page.waitForSelector('[data-qa="pdActivitiesHeader"]');
}

async function getLocalStorageData(page) {
    return await page.evaluate(() => {
      return Object.keys(localStorage).reduce(
          (items, curr) => ({
            ...items,
            [curr]: localStorage.getItem(curr)
          }),
          {}
      )
    });
  }

async function getSessionStorageData(page) {
    return page.evaluate(() => {
      return Object.keys(sessionStorage).reduce(
          (items, curr) => ({
           ...items,
           [curr]: sessionStorage.getItem(curr)
          }),
          {}
      )
    })
  } 


module.exports = {
    GetSession: async function (username, password, url) {
        const browser = await launchChromium();
        const context = await browser.newContext();
        const page = await context.newPage();
        await page.goto(url);
        await googleLogin(page, username, password);
        await page.waitForSelector('[data-qa="pdActivitiesHeader"]');
        // await page.waitForNavigation({
        //     waitUntil: `networkidle`
        // });
        const cookies = await context.cookies();
        const lsd = await getLocalStorageData(page);
        const ssd = await getSessionStorageData(page);
        await page.waitForSelector('[data-qa="pdActivitiesHeader"]');
        await page.waitForNavigation({
          waitUntil: `networkidle` 
      });
       await browser.close();
        return {
            cookies,
            lsd,
            ssd
        }
    }
};

