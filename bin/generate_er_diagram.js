// [bin/generate_er_diagram.js]

const fs = require('fs'); // ファイルシステムモジュールを読み込む
const path = require('path'); // パス操作モジュールを読み込む

// スキーマファイルのパス
const schemaPath = path.join(__dirname, '../db/schema.rb'); // スキーマファイルのパスを設定

// 日本時間での現在の日付を取得
const currentDate = new Date().toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" }).split(' ')[0].replace(/\//g, '-'); // 現在の日付を日本時間で取得し、フォーマットを修正

// 出力ファイルのパス
const outputFilePaths = {
  er: path.join(__dirname, `../Docs/ERD_${currentDate}.md`), // ER図の出力ファイルパス
  summary: path.join(__dirname, `../Docs/Summary_${currentDate}.md`) // サマリーの出力ファイルパス
};

// Docsディレクトリが存在しない場合は作成する
const outputDir = path.join(__dirname, '../Docs'); // 出力ディレクトリのパスを設定
if (!fs.existsSync(outputDir)) { // 出力ディレクトリが存在しない場合
  fs.mkdirSync(outputDir, { recursive: true }); // ディレクトリを再帰的に作成する
}

// 既存のファイルをチェックして削除
const existingFiles = fs.readdirSync(outputDir);
existingFiles.forEach(file => {
  if (file.match(/^ERD_\d{4}-\d{1,2}-\d{1,2}\.(md|pdf)$/) || file.match(/^Summary_\d{4}-\d{1,2}-\d{1,2}\.(md|pdf)$/)) {
    fs.unlinkSync(path.join(outputDir, file)); // 既存のファイルを削除
    console.log(`既存のファイルを削除しました: ${file}`);
  }
});

// ファイルの読み込み
function readFileSyncSafe(filePath, encoding = 'utf8') {
  try {
    return fs.readFileSync(filePath, encoding); // ファイルの内容を読み込む
  } catch (error) {
    console.error(`Error reading file ${filePath}:`, error); // エラーをコンソールに出力
    process.exit(1); // プロセスを終了
  }
}

// スキーマを読み込む
const schemaContent = readFileSyncSafe(schemaPath);

// データ型をMermaid用に小文字に変換する関数
function convertDataType(dataType) {
  return dataType.toLowerCase();
}

// スキーマをパースしてテーブル情報を抽出する関数
function parseSchema(schema) {
  const lines = schema.split('\n');
  let currentTable = null;
  const tables = {};

  lines.forEach(line => {
    const tableMatch = line.match(/create_table ['"](\w+)['"]/);
    if (tableMatch) {
      currentTable = tableMatch[1].toLowerCase();
      tables[currentTable] = { columns: [], primaryKeys: [], foreignKeys: [] };
    } else if (currentTable) {
      const columnMatch = line.match(/t\.(\w+) ['"](\w+)['"]/);
      if (columnMatch) {
        const dataType = columnMatch[1];
        const columnName = columnMatch[2].toLowerCase();
        tables[currentTable].columns.push({ name: columnName, type: convertDataType(dataType) });
      }
      // 主キーの取得
      const primaryKeyMatch = line.match(/t\.primary_key ['"](\w+)['"]/);
      if (primaryKeyMatch) {
        const pkName = primaryKeyMatch[1].toLowerCase();
        tables[currentTable].primaryKeys.push(pkName);
      }
      // 外部キーの取得
      const fkMatch = line.match(/add_foreign_key ['"](\w+)['"], ['"](\w+)['"]/);
      if (fkMatch) {
        const columnName = fkMatch[1].toLowerCase();
        const referenceTable = fkMatch[2].toLowerCase();
        tables[currentTable].foreignKeys.push({ columnName, referenceTable });
      }
    }
    if (line.trim() === 'end') {
      currentTable = null;
    }
  });

  return tables;
}

// 外部キーを解析する関数
function parseForeignKeys(schema) {
  const lines = schema.split('\n');
  const foreignKeys = {};

  lines.forEach(line => {
    const foreignKeyMatch = line.match(/add_foreign_key ['"](\w+)['"], ['"](\w+)['"]/);
    if (foreignKeyMatch) {
      const fromTable = foreignKeyMatch[1].toLowerCase();
      const toTable = foreignKeyMatch[2].toLowerCase();
      if (!foreignKeys[fromTable]) {
        foreignKeys[fromTable] = [];
      }
      foreignKeys[fromTable].push(toTable);
    }
  });

  return foreignKeys;
}

// スキーマからリレーションシップを取得
const parsedSchema = parseSchema(schemaContent);
const foreignKeys = parseForeignKeys(schemaContent);

// リレーションシップを見つける関数
function findSchemaRelationships(tables, foreignKeys) {
  const relationships = [];

  Object.keys(foreignKeys).forEach(fromTable => {
    foreignKeys[fromTable].forEach(toTable => {
      relationships.push({
        fromTable,
        toTable,
        column: `${fromTable.slice(0, -1)}_id`
      });
    });
  });

  return relationships;
}

const schemaRelationships = findSchemaRelationships(parsedSchema, foreignKeys);

// Mermaid形式のER図を生成する関数
function generateMermaidERD(tables, relationships) {
  let mermaidERD = '```mermaid\n erDiagram\n';

  // エンティティ情報を追加
  Object.keys(tables).forEach(table => {
    if (tables[table]) {
      mermaidERD += `  ${table} {\n`;
      tables[table].columns.forEach(column => {
        mermaidERD += `    ${column.name} ${column.type}\n`;
      });
      mermaidERD += '  }\n';
    }
  });

  // リレーションシップ情報を追加
  relationships.forEach(rel => {
    if (tables[rel.fromTable] && tables[rel.toTable]) {
      mermaidERD += `  ${rel.toTable} ||--o{ ${rel.fromTable} : "${rel.column}"\n`;
    }
  });

  mermaidERD += '```\n';
  return mermaidERD;
}

// サマリーテーブルを生成する関数
function generateSummaryTable(tables, relationships) {
  const tableHeaders = ['テーブル名', 'カラム数', 'PK数', 'FK数', 'belongs_to', 'has_many', 'has_one', 'has_and_belongs_to_many'];
  let tableContent = `| ${tableHeaders.join(' | ')} |\n| ${tableHeaders.map(() => '---').join(' | ')} |\n`;

  Object.keys(tables).forEach(table => {
    if (tables[table]) {
      const columnCount = tables[table].columns.length;
      const pkCount = tables[table].primaryKeys ? tables[table].primaryKeys.length : 0;
      const fkCount = tables[table].foreignKeys ? tables[table].foreignKeys.length : 0;
      const associations = {
        belongs_to: 0,
        has_many: 0,
        has_one: 0,
        has_and_belongs_to_many: 0
      };

      relationships.forEach(rel => {
        if (rel.fromTable === table) {
          if (rel.type === 'belongs_to') {
            associations.belongs_to++;
          } else if (rel.type === 'has_many') {
            associations.has_many++;
          } else if (rel.type === 'has_one') {
            associations.has_one++;
          } else if (rel.type === 'has_and_belongs_to_many') {
            associations.has_and_belongs_to_many++;
          }
        }
      });

      tableContent += `| ${table} | ${columnCount} | ${pkCount} | ${fkCount} | ${associations.belongs_to} | ${associations.has_many} | ${associations.has_one} | ${associations.has_and_belongs_to_many} |\n`;
    }
  });

  return tableContent;
}

const mermaidERDContentFromSchema = generateMermaidERD(parsedSchema, schemaRelationships);

const schemaSummaryTable = generateSummaryTable(parsedSchema, schemaRelationships);

const finalSummaryContent = `
# ERD Summary

## スキーマからのサマリー
${schemaSummaryTable}
`;

const finalERDContent = `
# ER Diagram

## ER図（スキーマから抽出）
${mermaidERDContentFromSchema}
`;

// 出力ファイルに書き出し
fs.writeFileSync(outputFilePaths.summary, finalSummaryContent, 'utf8');
fs.writeFileSync(outputFilePaths.er, finalERDContent, 'utf8');

console.log("ER図、サマリーテーブルの生成と修正が完了しました！");
