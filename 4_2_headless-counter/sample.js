// require関数が使えない...
const { Elm } = require("./elm.js");

// Elmプログラムの初期化
const app = Elm.Main.init();

// Elmプログラムからカウント中の数値を受け取る
app.ports.tick.subscribe(count => {
	console.log(count);
});