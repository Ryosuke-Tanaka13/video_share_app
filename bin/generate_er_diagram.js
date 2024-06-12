// bin/generate_er_diagram.js

const fs = require('fs');
const path = require('path');

// スキーマファイルのパス
const schemaPath = path.join(__dirname, '../db/schema.rb');
// モデルファイルのディレクトリ
const modelsPath = path.join(__dirname, '../app/models');
const modelFiles = fs.readdirSync(modelsPath).filter(file => file.endsWith('.rb'));

// スキーマをパースしてテーブル情報を抽出する関数
function parseSchema(schema) {
  const lines = schema.split('\n');
  let currentTable = null;
  const tables = {};

  lines.forEach(line => {
    const tableMatch = line.match(/create_table "(\w+)"/);
    if (tableMatch) {
      currentTable = tableMatch[1];
      tables[currentTable] = { columns: [], primaryKeys: [], foreignKeys: [] };
    } else if (currentTable) {
      const columnMatch = line.match(/t\.\w+ "(\w+)"(?:, (.+?))?$/);
      if (columnMatch) {
        const columnName = columnMatch[1];
        tables[currentTable].columns.push(columnName);
      }
      const primaryKeyMatch = line.match(/t\.primary_key "(\w+)"/);
      if (primaryKeyMatch) {
        tables[currentTable].primaryKeys.push(primaryKeyMatch[1]);
      }
      const fkMatch = line.match(/add_foreign_key "(\w+)", "(\w+)"/);
      if (fkMatch) {
        const fromTable = fkMatch[1];
        const toTable = fkMatch[2];
        tables[currentTable].foreignKeys.push({ fromTable, toTable });
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
      currentModel = classMatch[1];
      models[currentModel] = { associations: [] };
    } else if (currentModel) {
      const belongsToMatch = line.match(/belongs_to :(\w+)(?:, polymorphic: true)?/);
      const hasManyMatch = line.match(/has_many :(\w+)/);
      const hasOneMatch = line.match(/has_one :(\w+)/);
      const habtmMatch = line.match(/has_and_belongs_to_many :(\w+)/);

      if (belongsToMatch) {
        models[currentModel].associations.push({
          type: 'belongs_to',
          relatedModel: belongsToMatch[1],
          polymorphic: Boolean(belongsToMatch[2])
        });
      } else if (hasManyMatch) {
        models[currentModel].associations.push({ type: 'has_many', relatedModel: hasManyMatch[1] });
      } else if (hasOneMatch) {
        models[currentModel].associations.push({ type: 'has_one', relatedModel: hasOneMatch[1] });
      } else if (habtmMatch) {
        models[currentModel].associations.push({ type: 'has_and_belongs_to_many', relatedModel: habtmMatch[1] });
      }
    }
  });

  return models;
}

const models = {};

modelFiles.forEach(file => {
  const filePath = path.join(modelsPath, file);
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
      const fromTable = foreignKeyMatch[1];
      const toTable = foreignKeyMatch[2];
      if (!foreignKeys[fromTable]) {
        foreignKeys[fromTable] = [];
      }
      foreignKeys[fromTable].push(toTable);
    }
  });

  return foreignKeys;
}

// スキーマを読み込む
const schemaContent = fs.readFileSync(schemaPath, 'utf8');
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
        column: `${toTable.slice(0, -1)}_id`  // 外部キー名を推測
      });
    });
  });

  return relationships;
}

// スキーマからリレーションシップを取得
const relationships = findRelationships(parsedSchema, foreignKeys);

// モデルのリレーションをER図に反映するためにリレーションシップを抽出
function extractRelationshipsFromModels(models) {
  const relationships = [];

  Object.keys(models).forEach(model => {
    models[model].associations.forEach(assoc => {
      if (assoc.type === 'belongs_to') {
        relationships.push({
          fromTable: model.toLowerCase() + 's',
          toTable: assoc.polymorphic ? `${assoc.relatedModel}able` : assoc.relatedModel + 's',
          column: assoc.polymorphic ? `${assoc.relatedModel}_id` : `${assoc.relatedModel}_id`
        });
      }
    });
  });

  return relationships;
}

const modelRelationships = extractRelationshipsFromModels(models);

// スキーマからのリレーションシップとマージする
const combinedRelationships = [...relationships, ...modelRelationships];

// Mermaid形式のER図を生成する関数
function generateMermaidERD(tables, relationships) {
  let mermaidERD = '```mermaid\nerDiagram\n';

  Object.keys(tables).forEach(table => {
    mermaidERD += `  ${table} {\n`;
    tables[table].columns.forEach(column => {
      mermaidERD += `    ${column} string\n`;
    });
    tables[table].primaryKeys.forEach(pk => {
      mermaidERD += `    ${pk} PK\n`;
    });
    tables[table].foreignKeys.forEach(fk => {
      mermaidERD += `    ${fk.fromTable}_id FK\n`; // 外部キーとして扱う
    });
    mermaidERD += '  }\n';
  });

  relationships.forEach(rel => {
    mermaidERD += `  ${rel.fromTable} }|--o{ ${rel.toTable} : "${rel.column}"\n`;
  });

  mermaidERD += '```\n';
  return mermaidERD;
}

// Mermaid形式のER図を生成
const finalERDContent = generateMermaidERD(parsedSchema, combinedRelationships);

// Mermaid用のER図を生成するファイルのパス
const outputPaths = {
  entity: path.join(__dirname, '../Docs/Total_E_diagram.md'),
  relational: path.join(__dirname, '../Docs/Total_R_diagram.md'),
  final: path.join(__dirname, '../Docs/Total_ER_diagram.md'),
};

// ファイルに書き出す関数
function writeMermaidFile(filePath, content) {
  fs.writeFileSync(filePath, content, 'utf8');
  console.log(`ER図が生成されました: ${filePath}`);
}

// 各ファイルに書き出す
writeMermaidFile(outputPaths.entity, generateMermaidERD(parsedSchema, [])); // エンティティのみ
writeMermaidFile(outputPaths.relational, generateMermaidERD({}, combinedRelationships)); // リレーションのみ
writeMermaidFile(outputPaths.final, finalERDContent); // 完全版

// Mermaidコードの修正関数
function fixMermaidCode(content) {
  return content.replace(/\[.*\sindex/g, '')
                .replace(/^\s*$/gm, '')
                .replace(/\n{2,}/g, '\n');
}

// Mermaidコードを読み込み修正する関数
function cleanUpERDiagram(filePath) {
  try {
    let mermaidContent = fs.readFileSync(filePath, 'utf8');
    mermaidContent = fixMermaidCode(mermaidContent);
    fs.writeFileSync(filePath, mermaidContent, 'utf8');
    console.log(`修正されたER図が保存されました: ${filePath}`);
  } catch (error) {
    console.error(`ER図の修正中にエラーが発生しました: ${error.message}`);
  }
}

// ER図のクリーンアップを実行
cleanUpERDiagram(outputPaths.final);

console.log("ER図の生成と修正が完了しました！");
