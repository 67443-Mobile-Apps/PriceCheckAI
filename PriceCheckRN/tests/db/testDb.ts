import Database from 'better-sqlite3';
import { drizzle, type BetterSQLite3Database } from 'drizzle-orm/better-sqlite3';
import * as schema from '../../src/db/schema';
import { CREATE_TABLE_SQL } from '../../src/db/schema';

export type TestDb = BetterSQLite3Database<typeof schema>;

export function makeTestDb(): TestDb {
  const sqlite = new Database(':memory:');
  sqlite.exec(CREATE_TABLE_SQL);
  return drizzle(sqlite, { schema });
}
