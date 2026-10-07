import React, { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackScreenProps } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { Card, PriceTag, PrimaryButton, SecondaryButton } from '../theme/components';
import { colors, spacing, text } from '../theme/theme';
import { useHistoryStore } from '../stores/HistoryStoreContext';
import type { ScanStackParamList } from '../navigation/types';
import type { PriceLookup } from '../api/types';

type Props = NativeStackScreenProps<ScanStackParamList, 'Results'>;

const dateFormatter = new Intl.DateTimeFormat('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
});

export function ResultsScreen({ route }: Props) {
  const navigation = useNavigation<Props['navigation']>();
  const historyStore = useHistoryStore();
  const [saveError, setSaveError] = useState<string | null>(null);

  const { result } = route.params;

  const popToHome = () => {
    navigation.popToTop();
  };

  const save = (lookup: PriceLookup) => {
    try {
      historyStore.save(lookup);
      popToHome();
    } catch (err) {
      setSaveError(`Couldn't save: ${(err as Error).message}`);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.spacer} />

      <Card style={styles.card}>
        {result.kind === 'found' ? (
          <View style={styles.cardInner}>
            <Text style={[text.title, styles.itemName]}>{result.lookup.itemName}</Text>
            <PriceTag price={result.lookup.price} location={result.lookup.location} />
            <Text style={[text.caption, styles.dateText]}>
              {dateFormatter.format(result.lookup.date)}
            </Text>
          </View>
        ) : (
          <View style={styles.cardInner}>
            <Ionicons
              name="help-circle-outline"
              size={56}
              color={colors.onSurfaceMuted}
              accessibilityElementsHidden
              importantForAccessibility="no"
            />
            <Text style={[text.body, styles.notFoundText]}>
              No price found for this item.
            </Text>
          </View>
        )}
      </Card>

      <View style={styles.buttons}>
        {result.kind === 'found' ? (
          <PrimaryButton
            label="Save This Scan"
            onPress={() => save(result.lookup)}
            accessibilityHint="Saves this price to your history and returns to Home."
          />
        ) : null}
        <SecondaryButton
          label="Scan Another Item"
          onPress={popToHome}
          accessibilityHint="Returns to Home."
        />
        {saveError ? (
          <Text style={[text.caption, { color: colors.danger }]}>{saveError}</Text>
        ) : null}
      </View>

      <View style={styles.spacer} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.surface,
    paddingHorizontal: spacing.md,
    gap: spacing.lg,
  },
  spacer: {
    flex: 1,
  },
  card: {
    alignItems: 'center',
  },
  cardInner: {
    alignItems: 'center',
    gap: spacing.md,
    paddingVertical: spacing.md,
  },
  itemName: {
    color: colors.onSurface,
    textAlign: 'center',
  },
  dateText: {
    color: colors.onSurfaceMuted,
  },
  notFoundText: {
    color: colors.onSurface,
    textAlign: 'center',
  },
  buttons: {
    gap: spacing.sm,
  },
});
