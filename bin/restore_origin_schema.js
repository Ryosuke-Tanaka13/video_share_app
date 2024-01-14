// app/bin/restore_schema_for_setup.js

const fs = require('fs');
const path = require('path');

// スキーマファイルへのパス
const schemaPath = path.join(__dirname, '../db/schema.rb');
const originSchemaPath = path.join(__dirname, '../db/origin_schema.rb');

// 元々のスキーマファイルの内容を読み込む
const originSchemaContent = fs.readFileSync(originSchemaPath, 'utf8');

// 元々のスキーマファイルの内容をschema.rbに書き込む
fs.writeFileSync(schemaPath, originSchemaContent);

console.log(`Schema file restored to original state from ${originSchemaPath}`);
