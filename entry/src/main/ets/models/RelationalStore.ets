import { common } from '@kit.AbilityKit';
import { relationalStore, ValueType } from "@kit.ArkData";

export class RelationalStore {
  private static instance: RelationalStore;
  private rdbStore: relationalStore.RdbStore | undefined = undefined;

  private constructor() {}

  public static getInstance(): RelationalStore {
    if (!RelationalStore.instance) {
      RelationalStore.instance = new RelationalStore();
    }
    return RelationalStore.instance;
  }

  public async loadRdbStore(context: common.BaseContext, storeConfig: relationalStore.StoreConfig) {
    this.rdbStore = await relationalStore.getRdbStore(context, storeConfig);
  }

  public async execute(sql: string, bindArgs?: Array<relationalStore.ValueType>) {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    await this.rdbStore.executeSql(sql, bindArgs);
  }

  public async insert(
    table: string,
    values: relationalStore.ValuesBucket,
    conflict?: relationalStore.ConflictResolution
  ): Promise<number> {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    let rowId: number;
    if (conflict == undefined) {
      rowId = await this.rdbStore.insert(table, values);
    } else {
      rowId = await this.rdbStore.insert(table, values, conflict);
    }

    return rowId
  }

  public async update(
    values: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates,
    conflict?: relationalStore.ConflictResolution
  ): Promise<void> {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    await this.rdbStore.update(values, predicates, conflict);
  }

  public async delete(predicates: relationalStore.RdbPredicates) {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    await this.rdbStore.delete(predicates);
  }

  public async getAll(predicates: relationalStore.RdbPredicates, columns?: Array<string>): Promise<relationalStore.ValuesBucket[]> {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    let results: Array<relationalStore.ValuesBucket> = [];
    let resultSet = await this.rdbStore.query(predicates, columns);

    while (resultSet.goToNextRow()) {
      results.push(resultSet.getRow());
    }

    resultSet.close();
    return results;
  }

  public async getFirst(predicates: relationalStore.RdbPredicates, columns?: Array<string>): Promise<relationalStore.ValuesBucket> {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    let result: relationalStore.ValuesBucket;
    let resultSet = await this.rdbStore.query(predicates, columns);

    resultSet.goToFirstRow();
    result = resultSet.getRow();

    resultSet.close();
    return result;
  }

  public async querySql(sql: string, bindArgs?: Array<ValueType>): Promise<relationalStore.ValuesBucket[]> {
    if (this.rdbStore == undefined) throw new Error('Relational Database not loaded.');

    let results: Array<relationalStore.ValuesBucket> = [];
    let resultSet = await this.rdbStore.querySql(sql, bindArgs);

    while (resultSet.goToNextRow()) {
      results.push(resultSet.getRow());
    }

    resultSet.close();
    return results;
  }
}