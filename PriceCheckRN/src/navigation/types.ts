import type { PriceLookup } from '../api/types';

export type ScanResult =
  | { kind: 'found'; lookup: PriceLookup }
  | { kind: 'notFound'; barcode: string; location: string };

export type ScanStackParamList = {
  Home: undefined;
  ScanPicker: undefined;
  Results: { result: ScanResult };
};

export type HistoryStackParamList = {
  History: undefined;
};

export type RootTabParamList = {
  Scan: undefined;
  History: undefined;
};
