// app/bin/reorder_schema_for_setup.js

const fs = require('fs');
const path = require('path');

// スキーマファイルへのパス
const schemaPath = path.join(__dirname, '../db/schema.rb');
const reorderedSchemaPath = path.join(__dirname, '../db/reordered_schema.rb');
const originSchemaPath = path.join(__dirname, '../db/origin_schema.rb');

// 元のスキーマファイルを読み込む
const schemaContent = fs.readFileSync(schemaPath, 'utf8');

// スキーマファイルの全テーブルの定義と外部キー制約を取得
const createTableRegex = /create_table "(.*?)"(.*?)end/gms;
let match;
const tableDefinitions = {};
const foreignKeys = [];

while ((match = createTableRegex.exec(schemaContent)) !== null) {
  const [fullMatch, tableName, tableDefinition] = match;
  // インデントを修正してテーブル定義を格納
  let correctedTableDefinition = '  create_table "' + tableName + '"' + tableDefinition.replace(/\n    /g, '\n  ') + 'end';
  tableDefinitions[tableName] = correctedTableDefinition;
}

// 外部キー制約のインデントを整える
const addForeignKeyRegex = /add_foreign_key(.*?)\n/gms;
while ((match = addForeignKeyRegex.exec(schemaContent)) !== null) {
  foreignKeys.push('  ' + match[0].trim());
}

 // 裏スキーマに基づいて並び替えるテーブルの順序
const orderedTableNames = [
  "active_storage_attachments",
  "active_storage_variant_records",
  "active_storage_blobs",
  "replies",
  "comments",
  "video_folders",
  "folders",
  "organization_viewers",
  "videos",
  "users",
  "organizations",
  "system_admins",
  "viewers"
];

// 新しいスキーマファイルの生成
const reorderedSchema = 'ActiveRecord::Schema.define(version: 2022_11_27_114800) do\n\n' +
  orderedTableNames.map(tableName => tableDefinitions[tableName]).join('\n\n') +
  '\n\n' + foreignKeys.join('\n') + '\nend';

// 元のスキーマファイルをorigin_schema.rbにリネーム
fs.renameSync(schemaPath, originSchemaPath);

// 新しい並び替えられたスキーマをschema.rbとして保存
fs.writeFileSync(schemaPath, reorderedSchema);

console.log(`Original schema file is saved to ${originSchemaPath}`);
console.log(`Reordered schema file is saved to ${schemaPath}`);
