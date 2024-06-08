const { chromium } = require('playwright'); 
const express = require('express');
const app = express();
app.get('/', (req, res) => {
  res.send('Hello world!');
});

// دالة لفتح الصفحة والانتظار لمدة دقيقة
function openPage() {
  return new Promise(async (resolve, reject) => {
    const browser = await chromium.launch({ headless: true }); 
    const page = await browser.newPage(); 
    await page.goto('https://moroccoai-servers.koyeb.app/viewlogs/file');
    await page.waitForTimeout(60000);
    await browser.close();
    resolve();
  });
}

// دالة لتنفيذ العملية 100 مرة بشكل متزامن
async function executeInParallel() {
  const promises = [];
  for (let i = 0; i < 100; i++) {
    promises.push(openPage());
  }
  await Promise.all(promises);
}

// دالة لتكرار العملية بشكل لا نهائي
async function repeatForever() {
  while (true) {
    await executeInParallel();
  }
}

repeatForever();

app.listen(8080, () => {
  console.log('server is running on port 8080');
});
