const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// 静态文件目录改为public
app.use(express.static(path.join(__dirname, 'public')));

app.listen(PORT, () => {
    console.log(`NPM demo server running at http://0.0.0.0:${PORT}`);
}); 