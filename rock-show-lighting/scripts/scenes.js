const { chromium } = require('playwright');
const {setScene,URL}=require('./ll.js');
// [brightness 1-100, hue 1-360]; brightness 50 = full saturated colour, >50 adds white
const OFF=[1,1];
const S={
 '1_verse_blue':   {cyc:[14,235], side:[16,240], top:OFF, gobo:0, foot:0, specials:[]},
 '2_chorus_warm':  {cyc:[50,28],  side:[72,22],  top:[70,40], gobo:35, foot:45, specials:[]},
 '3_guitar_solo':  {cyc:OFF, side:OFF, top:OFF, gobo:0, foot:0, specials:['DR']},
 '4_blackout':     {cyc:OFF, side:OFF, top:OFF, gobo:0, foot:0, specials:[]},
 '5_strobe_flash': {cyc:[100,1], side:[100,1], top:[100,1], gobo:100, foot:100, specials:[]},
};
(async()=>{
  const b=await chromium.launch();
  const p=await b.newPage({viewport:{width:1440,height:900},deviceScaleFactor:2});
  await p.goto(URL,{waitUntil:'load'}); await p.waitForTimeout(1500);
  for(const [k,s] of Object.entries(S)){ await setScene(p,s); await p.screenshot({path:`../screenshots/${k}.png`}); }
  // strobe: alternate flash / blackout frames
  for(let i=0;i<8;i++){ await setScene(p, i%2==0?S['5_strobe_flash']:S['4_blackout']); await p.screenshot({path:`../screenshots/strobe_${i}.png`, clip:{x:300,y:190,width:1000,height:460}}); }
  // verify blackout is truly dark
  console.log(JSON.stringify(await p.evaluate(()=>[...document.querySelectorAll('img.viewport')].map(i=>i.id+':'+getComputedStyle(i).opacity))));
  await b.close();
})();
