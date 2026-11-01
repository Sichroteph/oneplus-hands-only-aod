const fs = require('fs');
const vm = require('vm');
const assert = require('assert');
const path = require('path');
if (!process.argv[2]) throw Error('Usage: node test-matrice-metrique.cjs CASE_DIRECTORY');
const dir = path.resolve(process.argv[2]);
const original = fs.readFileSync(path.join(dir, 'original-main.js'), 'utf8');
const candidate = fs.readFileSync(path.join(dir, 'candidate-main.js'), 'utf8');
const resources = fs.readFileSync(path.join(dir, 'js_asset.js'), 'utf8');
let events = 0;
for (let style = 0; style < 4; style++) {
  for (const palette of ['default', 'custom', 'missing']) {
    const images = [], views = [];
    let page;
    const state = {hour: 0, min: 0, sec: 0, updataFlag: 3};
    const data = new Uint8Array(palette === 'custom' ? 48 : 16);
    data[0] = style;
    if (palette === 'custom') {data[12] = 8; data.fill(255, 16);}
    const context = vm.createContext({
      print() {}, Uint8Array, Array, Object,
      ImageRelativePath() {}, Watchface: () => state,
      FileManager: () => ({readFile({success, fail}) {
        if (palette === 'missing') fail(1); else success({data: data.buffer});
      }}),
      Image(parent, pic, x, y) {
        const image = {pic, x, y, setPic(p) {this.pic = p;},
          setPivot(x, y) {this.pivot = [x,y];}, setAngle(a) {this.angle = a;},
          setColor() {throw Error('Unexpected image recoloring');}};
        images.push(image); return image;
      },
      EditWidget() {throw Error('Unexpected complication');},
      Label() {throw Error('Unexpected label');},
      View(parent,x,y,w,h) {
        const view = {x,y,w,h,setLocalStyle(s) {this.style=s;}};
        views.push(view);return view;
      },
      WatchfaceUpdata: {hour: 1, min: 2},
      WindowEvent: Object.fromEntries(['winTop','winResume','winReenter','minTimeout',
        'secTimeout','winRepaint','timeChange'].map((name,i)=>[name,i])),
      subwm: {registerSubWindow(p) {page=p;return true;}}
    });
    context.require = () => vm.runInContext(resources, context);
    vm.runInContext(candidate, context);
    const view = page.onCreate({},466,466);
    assert.equal(images.length,2);
    assert.equal(views.length,1);
    assert.equal(view.style['main:default']['bg-color'],0);
    assert.equal(images[0].pic,context.PicId.Picic_hand_hour);
    assert.equal(images[1].pic,context.PicId.Picic_hand_minute);
    for (const image of images) {
      assert.equal(image.x+image.pivot[0],233);
      assert.equal(image.y+image.pivot[1],233);
    }
    const originalContext = vm.createContext({require() {}, subwm: {registerSubWindow(p) {this.page=p;return true;}}});
    vm.runInContext(original,originalContext);
    const originalPage = originalContext.subwm.page;
    for (const name of ['drawTime','drawTimePos','readUserData','initEditInfo']) {
      assert.equal(page[name].toString().replace(/\r\n/g,'\n'),originalPage[name].toString().replace(/\r\n/g,'\n'),name+' changed');
    }
    for (let hour=0;hour<24;hour++) for(let min=0;min<60;min++) {
      state.hour=hour;state.min=min;
      for (const sec of [0,37]) {
        state.sec=sec;page.onEvent(context.WindowEvent.minTimeout);
        assert.equal(images[0].angle,hour*300+min*5);
        assert.equal(images[1].angle,min*60+sec);
        assert(Math.abs(view.x)<=6 && Math.abs(view.y)<=6);
        assert.equal(images.length,2);events++;
      }
    }
    assert.notEqual(page.aodPos,0);
    for (const event of Object.values(context.WindowEvent)) page.onEvent(event);
  }
}
console.log(`PASS: 4 styles x 3 palettes; ${events} time updates; exactly 2 hand images, one black view, pivots and original anti-burn-in/time logic.`);
