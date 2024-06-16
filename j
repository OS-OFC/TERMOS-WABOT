const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: false }); // فتح المتصفح بوضع غير الرأس
  const page = await browser.newPage(); // فتح صفحة جديدة
  await page.goto('https://fb.com'); // الذهاب إلى موقع فيسبوك

  // استخدام setTimeout للانتظار لمدة دقيقة واحدة
  setTimeout(async () => {
    await browser.close(); // إغلاق المتصفح بعد الانتظار
  }, 60000);
})();
