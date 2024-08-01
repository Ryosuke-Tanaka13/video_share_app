// [bin/generate_PK_FK_counter.js]

const fs = require('fs'); // ファイルシステムモジュールを読み込む
const path = require('path'); // パス操作モジュールを読み込む

// スキーマファイルのパス
const schemaPath = path.join(__dirname, '../db/schema.rb'); // スキーマファイルのパスを設定
// 日本時間での現在の日付を取得
const currentDate = new Date().toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" }).split(' ')[0].replace(/\//g, '-'); // 現在の日付を日本時間で取得し、フォーマットを修正

// 出力ファイルのパス
const outputFilePath = path.join(__dirname, `../Docs/PK_FK_count_${currentDate}.md`); // 出力ファイルのパスを設定

// Docsディレクトリが存在しない場合は作成する
const outputDir = path.join(__dirname, '../Docs'); // 出力ディレクトリのパスを設定
if (!fs.existsSync(outputDir)) { // 出力ディレクトリが存在しない場合
  fs.mkdirSync(outputDir, { recursive: true }); // ディレクトリを再帰的に作成する
}

// 既存のファイルをチェックして削除
const existingFiles = fs.readdirSync(outputDir);
existingFiles.forEach(file => {
  if (file.match(/^PK_FK_count_\d{4}-\d{1,2}-\d{1,2}\.(md|pdf)$/)) {
    fs.unlinkSync(path.join(outputDir, file)); // 既存のファイルを削除
    console.log(`既存のファイルを削除しました: ${file}`);
  }
});

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
