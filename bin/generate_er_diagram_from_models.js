// [bin/generate_er_diagram_from_models.js]

// 必要なモジュールの読み込み
const fs = require('fs'); // ファイルシステムモジュールを読み込む
const path = require('path'); // パス操作モジュールを読み込む

// モデルファイルのディレクトリパス
const modelsDir = path.join(__dirname, '../app/models'); // モデルファイルが格納されているディレクトリのパスを設定

// 日本時間での現在の日付を取得
const currentDate = new Date().toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" }).split(' ')[0].replace(/\//g, '-'); // 現在の日付を日本時間で取得し、フォーマットを修正

// 出力ファイルのパス
const outputFilePaths = {
  er: path.join(__dirname, `../Docs/ERD_from_models_${currentDate}.md`), // ER図の出力ファイルパス
  summary: path.join(__dirname, `../Docs/Summary_from_models_${currentDate}.md`) // サマリーの出力ファイルパス
};

// Docsディレクトリが存在しない場合は作成する
const outputDir = path.join(__dirname, '../Docs'); // 出力ディレクトリのパスを設定
if (!fs.existsSync(outputDir)) { // 出力ディレクトリが存在しない場合
  fs.mkdirSync(outputDir, { recursive: true }); // ディレクトリを再帰的に作成する
}

// モデルファイルからER図情報を抽出する関数
function extractModelInfo(filePath) {
  const content = fs.readFileSync(filePath, 'utf8'); // ファイルの内容を読み込む
  const tableNameMatch = content.match(/class\s+(\w+)/); // クラス名を正規表現で取得
  const tableName = tableNameMatch ? tableNameMatch[1].toLowerCase() : null; // クラス名を小文字に変換してテーブル名とする

  if (!tableName) return null; // テーブル名が無い場合はnullを返す

  const columns = []; // カラム情報を格納する配列
  const columnMatches = [...content.matchAll(/t\.(\w+)\s*:\s*["']?(\w+)["']?/g)]; // カラム情報を正規表現で取得
  columnMatches.forEach(match => {
    const columnName = match[2]; // カラム名
    const columnType = match[1] ? match[1].toLowerCase() : 'string'; // データ型を小文字に変換
    columns.push({ name: columnName, type: columnType }); // カラム情報を配列に追加
  });

  const relationships = []; // リレーション情報を格納する配列
  const relationshipPatterns = [
    { pattern: /belongs_to\s*:\s*["']?(\w+)["']?/g, type: 'belongs_to' }, // belongs_to のリレーションを取得
    { pattern: /has_many\s*:\s*["']?(\w+)["']?/g, type: 'has_many' }, // has_many のリレーションを取得
    { pattern: /has_one\s*:\s*["']?(\w+)["']?/g, type: 'has_one' }, // has_one のリレーションを取得
    { pattern: /has_and_belongs_to_many\s*:\s*["']?(\w+)["']?/g, type: 'has_and_belongs_to_many' } // has_and_belongs_to_many のリレーションを取得
  ];
  relationshipPatterns.forEach(({ pattern, type }) => {
    const matches = [...content.matchAll(pattern)];
    matches.forEach(match => relationships.push({ type, target: match[1].toLowerCase() })); // リレーション情報を配列に追加
  });

  return { tableName, columns, relationships }; // テーブル情報を返す
}

// モデルディレクトリからすべてのモデル情報を取得する関数
function getAllModelsInfo(modelsDir) {
  const files = fs.readdirSync(modelsDir); // ディレクトリ内のファイル一覧を取得
  const modelsInfo = [];

  files.forEach(file => {
    const filePath = path.join(modelsDir, file);
    if (path.extname(filePath) === '.rb') { // Rubyファイルのみを対象
      const modelInfo = extractModelInfo(filePath); // モデル情報を抽出
      if (modelInfo) {
        modelsInfo.push(modelInfo); // モデル情報を配列に追加
      }
    }
  });

  return modelsInfo; // すべてのモデル情報を返す
}

// ER図をMermaid形式で生成する関数
function generateMermaidERD(modelsInfo) {
  let mermaidERD = '```mermaid\nerDiagram\n';

  modelsInfo.forEach(model => {
    mermaidERD += `  ${model.tableName} {\n`;
    model.columns.forEach(column => {
      mermaidERD += `    ${column.name} ${column.type}\n`; // カラム情報を追加
    });
    mermaidERD += '  }\n';
  });

  modelsInfo.forEach(model => {
    model.relationships.forEach(rel => {
      if (rel.type === 'belongs_to') {
        mermaidERD += `  ${model.tableName} ||--o{ ${rel.target} : "${rel.target}_id"\n`; // belongs_to のリレーションを追加
      } else if (rel.type === 'has_many') {
        mermaidERD += `  ${rel.target} ||--o{ ${model.tableName} : "${model.tableName}_id"\n`; // has_many のリレーションを追加
      } else if (rel.type === 'has_one') {
        mermaidERD += `  ${rel.target} ||--|| ${model.tableName} : "${model.tableName}_id"\n`; // has_one のリレーションを追加
      } else if (rel.type === 'has_and_belongs_to_many') {
        mermaidERD += `  ${model.tableName} }|--|{ ${rel.target} : "many_to_many"\n`; // has_and_belongs_to_many のリレーションを追加
      }
    });
  });

  mermaidERD += '```\n';
  return mermaidERD; // Mermaid形式のER図を返す
}

// スキーマ情報を表形式で生成する関数
function generateSchemaTable(modelsInfo) {
  const tableHeaders = ['テーブル名', 'カラム数', 'キー数', 'belongs_to', 'has_many', 'has_one', 'has_and_belongs_to_many'];
  let tableContent = `| ${tableHeaders.join(' | ')} |\n| ${tableHeaders.map(() => '---').join(' | ')} |\n`;

  modelsInfo.forEach(model => {
    const tableName = model.tableName;
    const columnCount = model.columns.length;
    const keyCount = model.columns.filter(col => col.name.endsWith('_id')).length;
    const associations = {
      belongs_to: 0,
      has_many: 0,
      has_one: 0,
      has_and_belongs_to_many: 0
    };

    model.relationships.forEach(rel => {
      if (associations[rel.type] !== undefined) {
        associations[rel.type]++;
      }
    });

    tableContent += `| ${tableName} | ${columnCount} | ${keyCount} | ${associations.belongs_to} | ${associations.has_many} | ${associations.has_one} | ${associations.has_and_belongs_to_many} |\n`;
  });

  return tableContent; // 表形式のスキーマ情報を返す
}

// メイン処理
const modelsInfo = getAllModelsInfo(modelsDir); // すべてのモデル情報を取得
const mermaidERDContent = generateMermaidERD(modelsInfo); // Mermaid形式のER図を生成
const schemaTableContent = generateSchemaTable(modelsInfo); // スキーマ情報の表を生成

const finalERDContent = `
# ER Diagram from Models

## ER Diagram(主にリレーション)
${mermaidERDContent}
`;

const finalSummaryContent = `
# ERD Summary from Models

## サマリー(主に外部キーを除くリレーション)
${schemaTableContent}
`;

// 出力ファイルに書き出し
fs.writeFileSync(outputFilePaths.er, finalERDContent, 'utf8');
fs.writeFileSync(outputFilePaths.summary, finalSummaryContent, 'utf8');

console.log(`ER図とサマリーが生成されました: ${outputFilePaths.er}, ${outputFilePaths.summary}`);
