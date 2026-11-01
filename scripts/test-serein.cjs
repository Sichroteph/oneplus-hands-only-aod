const fs = require('fs');
const vm = require('vm');
const assert = require('assert');
const path = require('path');
if (!process.argv[2]) throw Error('Usage: node test-serein.cjs CASE_DIRECTORY');
const dir = path.resolve(process.argv[2]);
for (let style = 0; style < 5; style++) {
  const images = [];
  let page;
  const state = { hour: 10, min: 8, sec: 0, updataFlag: 3 };
  const data = new Uint8Array(16); data[2] = style;
  const context = vm.createContext({
    print() {}, Uint8Array, Array, Object,
    ImageRelativePath() {}, Watchface: () => state,
    FileManager: () => ({ readFile: ({ success }) => success({ data: data.buffer }) }),
    Image: (parent, pic, x, y) => {
      const image = { pic, x, y, setPic(p) { this.pic = p; },
        setPivot(x, y) { this.pivot = [x, y]; }, setAngle(a) { this.angle = a; } };
      images.push(image); return image;
    },
    Label() { throw Error('Unexpected date label'); },
    EditWidget() { throw Error('Unexpected complication'); },
    View: () => ({ setLocalStyle(s) { this.style = s; } }),
    WatchfaceUpdata: { hour: 1, min: 2 },
    WindowEvent: Object.fromEntries(['winTop', 'winResume', 'winReenter',
      'winAnimationDone', 'minTimeout', 'secTimeout', 'winRepaint', 'timeChange'].map((s, i) => [s, i])),
    subwm: { registerSubWindow(p) { page = p; return true; } },
  });
  context.require = () => vm.runInContext(fs.readFileSync(path.join(dir, 'js_asset.js'), 'utf8'), context);
  vm.runInContext(fs.readFileSync(path.join(dir, 'candidate-main.js'), 'utf8'), context);
  const view = page.onCreate({}, 466, 466);
  assert.equal(view.style['main:default']['bg-color'], 0);
  assert.equal(images.length, 2);
  assert.equal(images[0].pic, 46 + style);
  assert.equal(images[1].pic, 56 + style);
  for (const image of images) {
    assert.equal(image.x + image.pivot[0], 233);
    assert.equal(image.y + image.pivot[1], 233);
  }
  for (let minute = 0; minute < 60; minute++) {
    state.min = minute; page.onEvent(context.WindowEvent.minTimeout);
    assert.equal(images[0].angle, Math.floor((10 * 3600 + minute * 60) / 12));
    assert.equal(images[1].angle, minute * 60);
    assert.ok(Math.abs(view.x || 0) <= 6 && Math.abs(view.y || 0) <= 6);
  }
}
console.log('PASS: all 5 hand styles, 60 minute updates, exactly 2 images, black background and pixel shifting.');
