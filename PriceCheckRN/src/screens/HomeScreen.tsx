import React from 'react';
import {
  ActionSheetIOS,
  Platform,
  Pressable,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import type { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import {
  BrandGradient,
  Card,
  LocationBadge,
  PrimaryButton,
} from '../theme/components';
import { colors, spacing, text } from '../theme/theme';
import { useLocationStore } from '../stores/LocationStore';
import type { ScanStackParamList } from '../navigation/types';

type Nav = NativeStackNavigationProp<ScanStackParamList, 'Home'>;

export function HomeScreen() {
  const navigation = useNavigation<Nav>();
  const insets = useSafeAreaInsets();
  const { all, current, setCurrent } = useLocationStore();

  const openPicker = () => {
    if (all.length === 0) return;

    if (Platform.OS === 'ios') {
      const options = [...all, 'Cancel'];
      const cancelButtonIndex = options.length - 1;
      ActionSheetIOS.showActionSheetWithOptions(
        {
          title: 'Choose a location',
          options,
          cancelButtonIndex,
          userInterfaceStyle: 'light',
        },
        (index) => {
          if (index !== cancelButtonIndex) setCurrent(all[index]);
        },
      );
    } else {
      // Android fallback: cycle to next chain. Replaced with a proper modal
      // if/when Android is in scope.
      const i = all.indexOf(current);
      setCurrent(all[(i + 1) % all.length]);
    }
  };

  return (
    <View style={styles.container}>
      <BrandGradient style={[styles.header, { paddingTop: insets.top + spacing.lg }]}>
        <Text style={[text.titleXL, styles.headerTitle]}>PriceCheck</Text>
        <Text style={[text.body, styles.headerTagline]}>
          Scan a barcode. See what it costs.
        </Text>
      </BrandGradient>

      <View style={styles.content}>
        <Card>
          <Text style={[text.caption, styles.cardLabel]}>Your location</Text>
          <Pressable
            onPress={openPicker}
            disabled={all.length === 0}
            accessibilityRole="button"
            accessibilityLabel="Change location"
            accessibilityValue={{ text: current || 'Loading' }}
            style={styles.pickerRow}
          >
            <LocationBadge location={current || 'Loading…'} />
            <Ionicons
              name="chevron-expand-outline"
              size={18}
              color={colors.onSurfaceMuted}
              accessibilityElementsHidden
              importantForAccessibility="no"
            />
          </Pressable>
        </Card>

        <PrimaryButton
          label="Price Scan"
          leftIcon={<Ionicons name="barcode-outline" size={22} color={colors.white} />}
          onPress={() => navigation.navigate('ScanPicker')}
          disabled={!current}
          accessibilityHint={`Opens the barcode picker for ${current || 'the current location'}.`}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.surface,
  },
  header: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.xl,
  },
  headerTitle: {
    color: colors.white,
  },
  headerTagline: {
    color: colors.white,
    opacity: 0.9,
    marginTop: spacing.xs,
  },
  content: {
    padding: spacing.md,
    gap: spacing.lg,
  },
  cardLabel: {
    color: colors.onSurfaceMuted,
    marginBottom: spacing.sm,
  },
  pickerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: spacing.sm,
  },
});
