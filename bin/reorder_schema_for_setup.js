// app/bin/reorder_schema_for_setup.js

const fs = require('fs');
const path = require('path');

// スキーマファイルへのパス
const schemaPath = path.join(__dirname, '../db/schema.rb');
const originSchemaPath = path.join(__dirname, '../db/origin_schema.rb');

// 元のスキーマファイルを読み込む
const schemaContent = fs.readFileSync(schemaPath, 'utf8');

// スキーマファイルの全テーブルの定義と外部キー制約を取得
const createTableRegex = /create_table "(.*?)"(.*?)end/gms;

// 外部キー制約の取得用正規表現
// 既に宣言されている addForeignKeyRegex を更新する代わりに、ここで初めて宣言する
const addForeignKeyRegex = /add_foreign_key "(.*?)", "(.*?)"(?:, column: "(.*?)")?/gms;

let match;
const tableDefinitions = {};
const dependencies = {};
const foreignKeys = [];

while ((match = createTableRegex.exec(schemaContent)) !== null) {
  const [fullMatch, tableName, tableDefinition] = match;
  // インデントを修正してテーブル定義を格納
  let correctedTableDefinition = '  create_table "' + tableName + '"' + tableDefinition.replace(/\n    /g, '\n  ') + '  end';
  tableDefinitions[tableName] = correctedTableDefinition;
  dependencies[tableName] = new Set(); // 依存関係の初期化
}

// 依存関係の解析と外部キー制約の収集
while ((match = addForeignKeyRegex.exec(schemaContent)) !== null) {
  const [fullMatch, sourceTable, targetTable, column] = match;
  const columnPart = column ? `, column: "${column}"` : '';
  foreignKeys.push(`add_foreign_key "${sourceTable}", "${targetTable}"${columnPart}`);

  if (!dependencies[targetTable]) {
    dependencies[targetTable] = new Set();
  }
  dependencies[targetTable].add(sourceTable);
}

// トポロジカルソートを用いて依存関係に基づくテーブルの順序を決定
const orderedTableNames = topologicalSort(dependencies);

// スキーマファイルからバージョン番号を抽出
const versionRegex = /ActiveRecord::Schema\.define\(version: (\d{4}_\d{2}_\d{2}_\d{6})\) do/;
const versionMatch = schemaContent.match(versionRegex);
const schemaVersion = versionMatch ? versionMatch[1] : 'unknown';

// 新しいスキーマファイルの生成
const reorderedSchema = `ActiveRecord::Schema.define(version: ${schemaVersion}) do\n\n` +
  orderedTableNames.map(tableName => tableDefinitions[tableName]).join('\n\n') +
  '\n\n' + foreignKeys.join('\n') + '\nend';

// 並べ替えたスキーマファイルを別のファイルreorderd_schema.rbに保存
const reorderedSchemaPath = path.join(__dirname, '../db/reordered_schema.rb');
fs.writeFileSync(reorderedSchemaPath, reorderedSchema);

// 元々のスキーマファイルを別のファイルorigin_schema.rbにバックアップとして保存
fs.copyFileSync(schemaPath, originSchemaPath);

// 新しく生成したスキーマファイルをschema.rbとして保存
fs.writeFileSync(schemaPath, reorderedSchema);

console.log(`Original schema file is saved to ${originSchemaPath}`);
console.log(`Reordered schema file is saved to ${reorderedSchemaPath}`);
console.log(`New schema file is saved to ${schemaPath}`);
// トポロジカルソートの実装
function topologicalSort(dependencies) {
  let sorted = [];
  let noDependents = Object.keys(dependencies).filter(table => dependencies[table].size === 0);

  while (noDependents.length) {
    let node = noDependents.pop();
    sorted.push(node);

    Object.keys(dependencies).forEach(table => {
      if (dependencies[table].has(node)) {
        dependencies[table].delete(node);
        if (dependencies[table].size === 0) {
          noDependents.push(table);
        }
      }
    });
  }

  // 循環依存がある場合、エラーを投げる
  if (Object.values(dependencies).some(dependency => dependency.size !== 0)) {
    throw new Error("循環依存が存在するため、トポロジカルソートが不可能です");
  }

  return sorted;
}
