#!/usr/bin/env node
// Node skips the first line if it starts with #!, so the shebang doesn't break JS syntax
const data = JSON.parse(require('fs').readFileSync(process.argv[2], 'utf8'));
const pods = data.items.filter(p => p.status.phase !== 'Running').map(p => p.metadata.name);
console.log(pods);