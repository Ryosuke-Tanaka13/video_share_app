// [bin/generate_PK_FK_counter.js]

const fs = require('fs');
const path = require('path');

// スキーマファイルのパス
const schemaPath = path.join(__dirname, '../db/schema.rb');
// 日本時間での現在の日付を取得
const currentDate = new Date().toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" }).split(' ')[0].replace(/\//g, '-');
// 出力ファイルのパス
const outputFilePath = path.join(__dirname, `../Docs/PK_FK_count_${currentDate}.md`);

// Docsディレクトリが存在しない場合は作成する
const outputDir = path.join(__dirname, '../Docs');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

// ファイルの読み込み
function readFileSyncSafe(filePath, encoding = 'utf8') {
  try {
    return fs.readFileSync(filePath, encoding);
  } catch (error) {
    console.error(`Error reading file ${filePath}:`, error);
    process.exit(1);
  }
}

// スキーマを読み込む
const schemaContent = readFileSyncSafe(schemaPath);

// スキーマをパースしてテーブル情報を抽出する関数
function parseSchemaForPKFK(schema) {
  const lines = schema.split('\n');
  let currentTable = null;
  const tables = {};

  lines.forEach(line => {
    // テーブル作成行を識別
    const tableMatch = line.match(/create_table\s+"(\w+)"/);
    if (tableMatch) {
      currentTable = tableMatch[1];
      tables[currentTable] = { primaryKeys: 0, foreignKeys: 0 };
    }

    // プライマリキーと外部キーの行を識別
    if (currentTable) {
      if (line.includes('t.index') && line.includes('unique: true')) {
        tables[currentTable].primaryKeys += 1;
      }
    }

    // 外部キーを識別
    const fkMatch = line.match(/add_foreign_key\s+"(\w+)"/);
    if (fkMatch) {
      const fkTable = fkMatch[1];
      if (tables[fkTable]) {
        tables[fkTable].foreignKeys += 1;
      }
    }

    // テーブル定義の終了を識別
    if (line.trim() === 'end') {
      currentTable = null;
    }
  });

  return tables;
}

// テーブル情報からサマリーテーブルを生成する関数
function generatePKFKSummaryTable(tables) {
  const tableHeaders = ['テーブル名', 'PK数', 'FK数'];
  let tableContent = `| ${tableHeaders.join(' | ')} |\n| ${tableHeaders.map(() => '---').join(' | ')} |\n`;

  Object.keys(tables).forEach(table => {
    if (tables[table]) {
      const pkCount = tables[table].primaryKeys;
      const fkCount = tables[table].foreignKeys;

      tableContent += `| ${table} | ${pkCount} | ${fkCount} |\n`;
    }
  });

  return tableContent;
}

const parsedSchema = parseSchemaForPKFK(schemaContent);
const pkfkSummaryTable = generatePKFKSummaryTable(parsedSchema);

const finalSummaryContent = `
# PK and FK Count Summary

## スキーマからのサマリー
${pkfkSummaryTable}
`;

// 出力ファイルに書き出し
fs.writeFileSync(outputFilePath, finalSummaryContent, 'utf8');

console.log("PKとFKのカウントサマリーテーブルの生成が完了しました！");
