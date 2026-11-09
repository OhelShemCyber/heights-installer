const { chromium } = require('playwright');
const URL='https://scenicandlighting.com/lightlab/';
async function setScene(p, s){
  await p.evaluate((s)=>{
    const set=(id,v)=>{const e=document.getElementById(id); if(!e) return; e.value=v; e.dispatchEvent(new Event('input',{bubbles:true}));};
    set('CycColorPicker', s.cyc[1]); set('CycBrightnessPicker', s.cyc[0]);
    set('SideColorPicker', s.side[1]); set('SideBrightnessPicker', s.side[0]);
    set('TopColorPicker', s.top[1]); set('TopBrightnessPicker', s.top[0]);
    set(SLGobos.id, s.gobo||0); set(SRGobos.id, s.gobo||0); set('FootlightDimmer', s.foot||0);
    const all=['UR','UC','UL','RC','CS','LC','DR','DC','DL'];
    for(const a of all){ const want=(s.specials||[]).includes(a); const on=document[a+'SP']==-1; if(want!==on) window['switch'+a](a); }
    UpdateSpecials();
  }, s);
  await p.waitForTimeout(400);
}
module.exports={setScene,URL};
if (require.main===module) (async()=>{
  const b=await chromium.launch(); const p=await b.newPage({viewport:{width:1440,height:900}});
  await p.goto(URL,{waitUntil:'load'}); await p.waitForTimeout(1500);
  console.log(await p.evaluate(()=>[SLGobos.id,SRGobos.id,Footlights.id]));
  for (const sp of ['UR','UC','UL','RC','CS','LC','DR','DC','DL']){
    await setScene(p,{cyc:[1,0],side:[1,0],top:[1,0],specials:[sp]});
    await p.screenshot({path:`sp_${sp}.png`, clip:{x:300,y:190,width:1000,height:460}});
  }
  await b.close();
})();
