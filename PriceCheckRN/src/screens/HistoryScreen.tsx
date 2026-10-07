import React, { useCallback, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { Card, LocationBadge, currencyFormatter } from '../theme/components';
import { colors, spacing, text } from '../theme/theme';
import { useHistoryStore } from '../stores/HistoryStoreContext';
import type { PriceObservation } from '../db/schema';

const dateFormatter = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
});

type Group = {
  barcode: string;
  itemName: string;
  observations: PriceObservation[];
};

export function HistoryScreen() {
  const historyStore = useHistoryStore();
  const [observations, setObservations] = useState<PriceObservation[]>([]);

  useFocusEffect(
    useCallback(() => {
      setObservations(historyStore.allObservations());
    }, [historyStore]),
  );

  if (observations.length === 0) {
    return <EmptyState />;
  }

  const groups = groupByBarcode(observations);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {groups.map((group) => (
        <GroupSection key={group.barcode} group={group} />
      ))}
    </ScrollView>
  );
}

function GroupSection({ group }: { group: Group }) {
  return (
    <View style={styles.group}>
      <View style={styles.groupHeader}>
        <Text style={[text.title, { color: colors.onSurface }]}>{group.itemName}</Text>
        <Text style={[text.mono, { color: colors.onSurfaceMuted }]}>{group.barcode}</Text>
      </View>
      <View style={styles.rows}>
        {group.observations.map((obs) => (
          <ObservationRow key={obs.id} observation={obs} />
        ))}
      </View>
    </View>
  );
}

function ObservationRow({ observation }: { observation: PriceObservation }) {
  const priceText = currencyFormatter.format(observation.price);
  const dateText = dateFormatter.format(observation.date);
  return (
    <Card
      // Collapse into one accessibility element with a spoken label.
      // (RN doesn't have accessibilityElement(.combine) — set accessible + label.)
    >
      <View
        style={styles.rowInner}
        accessible
        accessibilityLabel={`${priceText} at ${observation.location} on ${dateText}`}
      >
        <View style={styles.rowLeft}>
          <LocationBadge location={observation.location} />
          <Text style={[text.caption, { color: colors.onSurfaceMuted }]}>{dateText}</Text>
        </View>
        <Text style={[text.title, { color: colors.onSurface }]}>{priceText}</Text>
      </View>
    </Card>
  );
}

function EmptyState() {
  return (
    <View style={styles.empty}>
      <Ionicons name="time-outline" size={56} color={colors.onSurfaceMuted} />
      <Text style={[text.title, { color: colors.onSurface }]}>No scans yet.</Text>
      <Text style={[text.body, { color: colors.onSurfaceMuted }]}>Tap Scan to get started.</Text>
    </View>
  );
}

function groupByBarcode(observations: PriceObservation[]): Group[] {
  const map = new Map<string, PriceObservation[]>();
  for (const obs of observations) {
    const bucket = map.get(obs.barcode) ?? [];
    bucket.push(obs);
    map.set(obs.barcode, bucket);
  }

  const groups: Group[] = [];
  for (const [barcode, obs] of map) {
    const sorted = [...obs].sort((a, b) => b.date.getTime() - a.date.getTime());
    groups.push({ barcode, itemName: sorted[0].itemName, observations: sorted });
  }

  return groups.sort((a, b) =>
    a.itemName.localeCompare(b.itemName, undefined, { sensitivity: 'base' }),
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.surface,
  },
  content: {
    padding: spacing.md,
    gap: spacing.lg,
  },
  group: {
    gap: spacing.sm,
  },
  groupHeader: {
    gap: spacing.xs,
    paddingHorizontal: spacing.xs,
  },
  rows: {
    gap: spacing.sm,
  },
  rowInner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.md,
  },
  rowLeft: {
    gap: spacing.xs,
  },
  empty: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.md,
    backgroundColor: colors.surface,
    padding: spacing.lg,
  },
});
