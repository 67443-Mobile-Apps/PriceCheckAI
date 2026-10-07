import * as SQLite from 'expo-sqlite';
import { drizzle } from 'drizzle-orm/expo-sqlite';
import { CREATE_TABLE_SQL } from './schema';

export function openDatabase() {
  const sqlite = SQLite.openDatabaseSync('pricecheck.db');
  sqlite.execSync(CREATE_TABLE_SQL);
  return drizzle(sqlite);
}

export type DB = ReturnType<typeof openDatabase>;
