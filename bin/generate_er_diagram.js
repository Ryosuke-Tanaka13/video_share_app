const fs = require('fs'); // fsモジュールを読み込み
const path = require('path');

// スキーマファイルのパス
const schemaPath = path.join(__dirname, '../db/schema.rb');
// モデルファイルのディレクトリパス
const modelsDir = path.join(__dirname, '../app/models');
// 出力ファイルのパス
const outputFilePaths = {
  er: path.join(__dirname, '../Docs/Total_ER_Diagram.md'),
  r: path.join(__dirname, '../Docs/Total_R_Diagram.md')
};

// スキーマを読み込む
const schemaContent = fs.readFileSync(schemaPath, 'utf8');

// モデルファイルの一覧を取得
const modelFiles = fs.readdirSync(modelsDir).filter(file => file.endsWith('.rb'));

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
    const tableMatch = line.match(/create_table "(\w+)"/);
    if (tableMatch) {
      currentTable = tableMatch[1].toLowerCase();
      tables[currentTable] = { columns: [], primaryKeys: [], foreignKeys: [], indexes: [] };
    } else if (currentTable) {
      const columnMatch = line.match(/t\.(\w+) "(\w+)"/);
      if (columnMatch) {
        const dataType = columnMatch[1];
        const columnName = columnMatch[2].toLowerCase();
        tables[currentTable].columns.push({ name: columnName, type: convertDataType(dataType) });
      }
      const primaryKeyMatch = line.match(/t\.primary_key "(\w+)"/);
      if (primaryKeyMatch) {
        const pkName = primaryKeyMatch[1].toLowerCase();
        tables[currentTable].primaryKeys.push(pkName);
      }
      const fkMatch = line.match(/add_foreign_key "(\w+)", "(\w+)"/);
      if (fkMatch) {
        const fromTable = fkMatch[1].toLowerCase();
        const toTable = fkMatch[2].toLowerCase();
        tables[currentTable].foreignKeys.push({ fromTable, toTable });
      }
      const indexMatch = line.match(/add_index "(\w+)", \["(\w+)"\]/);
      if (indexMatch) {
        const tableName = indexMatch[1].toLowerCase();
        const columnName = indexMatch[2].toLowerCase();
        tables[currentTable].indexes.push({ tableName, columnName });
      }
      if (line.trim() === 'end') {
        currentTable = null;
      }
    }
  });

  return tables;
}

// モデルファイルを解析してリレーションを抽出する関数
function parseModel(fileContent) {
  const lines = fileContent.split('\n');
  let currentModel = null;
  const models = {};

  lines.forEach(line => {
    const classMatch = line.match(/class (\w+) < ApplicationRecord/);
    if (classMatch) {
      currentModel = classMatch[1].toLowerCase();
      models[currentModel] = { associations: [] };
    } else if (currentModel) {
      const belongsToMatch = line.match(/belongs_to :(\w+)(?:, polymorphic: true)?/);
      const hasManyMatch = line.match(/has_many :(\w+)/);
      const hasOneMatch = line.match(/has_one :(\w+)/);
      const habtmMatch = line.match(/has_and_belongs_to_many :(\w+)/);

      if (belongsToMatch) {
        models[currentModel].associations.push({
          type: 'belongs_to',
          relatedModel: belongsToMatch[1].toLowerCase(),
          polymorphic: Boolean(belongsToMatch[2])
        });
      } else if (hasManyMatch) {
        models[currentModel].associations.push({ type: 'has_many', relatedModel: hasManyMatch[1].toLowerCase() });
      } else if (hasOneMatch) {
        models[currentModel].associations.push({ type: 'has_one', relatedModel: hasOneMatch[1].toLowerCase() });
      } else if (habtmMatch) {
        models[currentModel].associations.push({ type: 'has_and_belongs_to_many', relatedModel: habtmMatch[1].toLowerCase() });
      }
    }
  });

  return models;
}

// すべてのモデル情報を取得
const models = {};

modelFiles.forEach(file => {
  const filePath = path.join(modelsDir, file);
  const content = fs.readFileSync(filePath, 'utf8');
  Object.assign(models, parseModel(content));
});

// 外部キーを解析する関数
function parseForeignKeys(schema) {
  const lines = schema.split('\n');
  const foreignKeys = {};

  lines.forEach(line => {
    const foreignKeyMatch = line.match(/add_foreign_key "(\w+)", "(\w+)"/);
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
function findRelationships(tables, foreignKeys) {
  const relationships = [];

  Object.keys(foreignKeys).forEach(fromTable => {
    foreignKeys[fromTable].forEach(toTable => {
      relationships.push({
        fromTable,
        toTable,
        column: `${fromTable.slice(0, -1)}_id`  // 外部キー名を推測
      });
    });
  });

  return relationships;
}

const relationships = findRelationships(parsedSchema, foreignKeys);

// モデルのリレーションをR図に反映するためにリレーションシップを抽出
function extractRelationshipsFromModels(models) {
  const relationships = [];

  Object.keys(models).forEach(model => {
    models[model].associations.forEach(assoc => {
      if (assoc.type === 'belongs_to') {
        relationships.push({
          fromTable: model,
          toTable: assoc.polymorphic ? `${assoc.relatedModel}able` : assoc.relatedModel,
          column: `${model}_id`
        });
      } else if (assoc.type === 'has_many' || assoc.type === 'has_one') {
        relationships.push({
          fromTable: model,
          toTable: assoc.relatedModel,
          column: `${assoc.relatedModel}_id`
        });
      }
    });
  });

  return relationships;
}

const modelRelationships = extractRelationshipsFromModels(models);

// Mermaid形式のER図を生成する関数（スキーマから取得）
function generateMermaidERD(tables, relationships) {
  let mermaidERD = '```mermaid\n erDiagram\n';

  // エンティティ情報を追加
  Object.keys(tables).forEach(table => {
    if (tables[table]) {
      mermaidERD += `  ${table} {\n`;
      tables[table].columns.forEach(column => {
        mermaidERD += `    ${column.name} ${column.type}`;
        if (tables[table].primaryKeys.includes(column.name)) {
          mermaidERD += ' pk';
        }
        if (tables[table].foreignKeys.some(fk => fk.fromTable === column.name.toLowerCase())) {
          mermaidERD += ' fk';
        }
        mermaidERD += '\n';
      });
      tables[table].indexes.forEach(index => {
        mermaidERD += `    index ${index.columnName}\n`;
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

// リレーション図（R図）を生成する関数（モデルから取得）
function generateRelationDiagram(relationships) {
  let relationDiagram = '```mermaid\n erDiagram\n';

  // リレーションシップ情報のみを追加
  relationships.forEach(rel => {
    relationDiagram += `  ${rel.toTable} ||--o{ ${rel.fromTable} : "${rel.column}"\n`;
  });

  relationDiagram += '```\n';
  return relationDiagram;
}

// ファイルに書き出す関数
function writeMermaidFile(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`ファイルが生成されました: ${filePath}`);
}

// スキーマとモデルの情報を表形式で表示する関数を追加
function generateSummaryTable(schema, models) {
  let summaryTable = `| テーブル名 | カラム数 | 主キー数 | 外部キー数 | belongs_to | has_many | has_one | has_and_belongs_to_many |\n`;
  summaryTable += `| ---------- | -------- | -------- | ---------- | ---------- | -------- | ------- | ---------------------- |\n`;

  Object.keys(schema).forEach(table => {
    const tableData = schema[table];
    const modelName = Object.keys(models).find(model => model === table);

    const columnCount = tableData.columns.length;
    const primaryKeyCount = tableData.primaryKeys.length;
    const foreignKeyCount = tableData.foreignKeys.length;

    const belongsToCount = modelName ? models[modelName].associations.filter(assoc => assoc.type === 'belongs_to').length : 0;
    const hasManyCount = modelName ? models[modelName].associations.filter(assoc => assoc.type === 'has_many').length : 0;
    const hasOneCount = modelName ? models[modelName].associations.filter(assoc => assoc.type === 'has_one').length : 0;
    const hasAndBelongsToManyCount = modelName ? models[modelName].associations.filter(assoc => assoc.type === 'has_and_belongs_to_many').length : 0;

    summaryTable += `| ${table} | ${columnCount} | ${primaryKeyCount} | ${foreignKeyCount} | ${belongsToCount} | ${hasManyCount} | ${hasOneCount} | ${hasAndBelongsToManyCount} |\n`;
  });

  return summaryTable;
}

// ER図とR図を生成してファイルに書き出す
const finalERDContent = generateMermaidERD(parsedSchema, relationships);
const finalRelationContent = generateRelationDiagram(modelRelationships);

const summaryContent = generateSummaryTable(parsedSchema, models);
const finalERDWithSummary = `${finalERDContent}\n\n## 検出された各種要素\n${summaryContent}`;
const finalRelationWithSummary = `${finalRelationContent}\n\n## 検出された各種要素\n${summaryContent}`;

writeMermaidFile(outputFilePaths.er, finalERDWithSummary); // ER図ファイル
writeMermaidFile(outputFilePaths.r, finalRelationWithSummary); // リレーション図ファイル

console.log("ER図とリレーション図の生成と修正が完了しました！");
console.log("スキーマとモデルの情報のサマリーがER図とリレーション図ファイルに追加されました！");
