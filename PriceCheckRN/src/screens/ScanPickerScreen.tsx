import React, { useEffect, useState } from 'react';
import {
  ActivityIndicator,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { Card } from '../theme/components';
import { colors, radius, spacing, text } from '../theme/theme';
import { usePriceAPI } from '../stores/PriceAPIContext';
import { useLocationStore } from '../stores/LocationStore';
import type { ScanStackParamList } from '../navigation/types';
import type { BarcodeEntry } from '../api/types';

type Nav = NativeStackNavigationProp<ScanStackParamList, 'ScanPicker'>;

const UNKNOWN_BARCODE = '000000000000';

export function ScanPickerScreen() {
  const navigation = useNavigation<Nav>();
  const api = usePriceAPI();
  const { current } = useLocationStore();

  const [entries, setEntries] = useState<BarcodeEntry[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    api
      .allBarcodes()
      .then((e) => {
        if (!cancelled) {
          setEntries(e);
          setIsLoading(false);
        }
      })
      .catch((err: Error) => {
        if (!cancelled) {
          setLoadError(`Couldn't load barcodes: ${err.message}`);
          setIsLoading(false);
        }
      });
    return () => {
      cancelled = true;
    };
  }, [api]);

  const scan = async (barcode: string) => {
    try {
      const lookup = await api.lookup(barcode, current);
      navigation.navigate('Results', {
        result: lookup
          ? { kind: 'found', lookup }
          : { kind: 'notFound', barcode, location: current },
      });
    } catch (err) {
      setLoadError(`Lookup failed: ${(err as Error).message}`);
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {isLoading ? (
        <ActivityIndicator style={styles.spinner} />
      ) : loadError ? (
        <Text style={[text.body, styles.error]}>{loadError}</Text>
      ) : (
        <>
          <View style={styles.header}>
            <Text style={[text.body, styles.hint]}>
              Pick a barcode to simulate scanning.
            </Text>
            <Text style={[text.caption, styles.subhint]}>
              Scanning at {current}
            </Text>
          </View>

          {entries.map((entry) => (
            <KnownRow key={entry.barcode} entry={entry} onPress={() => scan(entry.barcode)} location={current} />
          ))}

          <UnknownRow onPress={() => scan(UNKNOWN_BARCODE)} />
        </>
      )}
    </ScrollView>
  );
}

function KnownRow({
  entry,
  location,
  onPress,
}: {
  entry: BarcodeEntry;
  location: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={`${entry.item}, barcode ${entry.barcode}`}
      accessibilityHint={`Looks up the price at ${location}.`}
    >
      <Card>
        <View style={styles.rowInner}>
          <Ionicons name="barcode-outline" size={20} color={colors.brand} accessibilityElementsHidden importantForAccessibility="no" />
          <View style={styles.rowText}>
            <Text style={[text.body, styles.itemName]}>{entry.item}</Text>
            <Text style={[text.mono, styles.barcode]}>{entry.barcode}</Text>
          </View>
          <Ionicons name="chevron-forward" size={18} color={colors.onSurfaceMuted} accessibilityElementsHidden importantForAccessibility="no" />
        </View>
      </Card>
    </Pressable>
  );
}

function UnknownRow({ onPress }: { onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel="Simulate unknown barcode"
      accessibilityHint="Exercises the not-found path with a barcode that isn't in the catalog."
      style={styles.unknownRow}
    >
      <Ionicons name="help-circle-outline" size={20} color={colors.onSurfaceMuted} accessibilityElementsHidden importantForAccessibility="no" />
      <Text style={[text.body, { color: colors.onSurfaceMuted, flex: 1 }]}>
        Simulate unknown barcode
      </Text>
      <Ionicons name="chevron-forward" size={18} color={colors.onSurfaceMuted} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.surface,
  },
  content: {
    padding: spacing.md,
    gap: spacing.md,
  },
  spinner: {
    marginTop: spacing.xl,
  },
  error: {
    color: colors.danger,
    textAlign: 'center',
    marginTop: spacing.xl,
  },
  header: {
    gap: spacing.xs,
    marginBottom: spacing.sm,
  },
  hint: {
    color: colors.onSurfaceMuted,
  },
  subhint: {
    color: colors.onSurfaceMuted,
  },
  rowInner: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  rowText: {
    flex: 1,
    gap: spacing.xs,
  },
  itemName: {
    color: colors.onSurface,
    fontWeight: '600',
  },
  barcode: {
    color: colors.onSurfaceMuted,
  },
  unknownRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    padding: spacing.md,
    borderRadius: radius.medium,
    borderWidth: 1,
    borderColor: colors.divider,
    borderStyle: 'dashed',
  },
});
