import React, { type ReactNode } from 'react';
import {
  Pressable,
  Text,
  View,
  StyleSheet,
  type PressableProps,
  type ViewStyle,
  type TextStyle,
  type StyleProp,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import {
  brandGradientColors,
  colors,
  radius,
  shadow,
  spacing,
  text,
} from './theme';

// MARK: - BrandGradient

type BrandGradientProps = {
  style?: StyleProp<ViewStyle>;
  children?: ReactNode;
};

export function BrandGradient({ style, children }: BrandGradientProps) {
  return (
    <LinearGradient
      colors={brandGradientColors}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={style}
    >
      {children}
    </LinearGradient>
  );
}

// MARK: - Buttons

type ButtonProps = {
  label: string;
  onPress: PressableProps['onPress'];
  disabled?: boolean;
  leftIcon?: ReactNode;
  accessibilityHint?: string;
};

export function PrimaryButton({ label, onPress, disabled, leftIcon, accessibilityHint }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityHint={accessibilityHint}
      style={({ pressed }) => [
        styles.buttonBase,
        shadow.button,
        pressed && styles.buttonPressed,
        disabled && styles.buttonDisabled,
      ]}
    >
      <BrandGradient style={StyleSheet.absoluteFill} />
      {leftIcon ? <View style={styles.buttonIcon}>{leftIcon}</View> : null}
      <Text style={[text.title, styles.buttonLabelPrimary]}>{label}</Text>
    </Pressable>
  );
}

export function SecondaryButton({ label, onPress, disabled, leftIcon, accessibilityHint }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityHint={accessibilityHint}
      style={({ pressed }) => [
        styles.buttonBase,
        styles.secondaryButton,
        pressed && styles.buttonPressed,
        disabled && styles.buttonDisabled,
      ]}
    >
      {leftIcon ? <View style={styles.buttonIcon}>{leftIcon}</View> : null}
      <Text style={[text.title, styles.buttonLabelSecondary]}>{label}</Text>
    </Pressable>
  );
}

export function DestructiveButton({ label, onPress, disabled, leftIcon, accessibilityHint }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      disabled={disabled}
      accessibilityRole="button"
      accessibilityLabel={label}
      accessibilityHint={accessibilityHint}
      style={({ pressed }) => [
        styles.buttonBase,
        styles.destructiveButton,
        pressed && styles.buttonPressed,
        disabled && styles.buttonDisabled,
      ]}
    >
      {leftIcon ? <View style={styles.buttonIcon}>{leftIcon}</View> : null}
      <Text style={[text.title, styles.buttonLabelPrimary]}>{label}</Text>
    </Pressable>
  );
}

// MARK: - Card

export function Card({ style, children }: { style?: StyleProp<ViewStyle>; children: ReactNode }) {
  return <View style={[styles.card, shadow.card, style]}>{children}</View>;
}

// MARK: - LocationBadge

export function LocationBadge({ location }: { location: string }) {
  return (
    <View style={styles.badge}>
      <Ionicons name="location-outline" size={16} color={colors.brand} />
      <Text style={[text.body, styles.badgeText]}>{location}</Text>
    </View>
  );
}

// MARK: - PriceTag

const currencyFormatter = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD',
});

export function PriceTag({ price, location }: { price: number; location: string }) {
  return (
    <View style={styles.priceTag}>
      <Text style={[text.titleXL, { color: colors.onSurface }]}>
        {currencyFormatter.format(price)}
      </Text>
      <Text style={[text.caption, { color: colors.onSurfaceMuted }]}>at {location}</Text>
    </View>
  );
}

export { currencyFormatter };

// MARK: - Styles

const styles = StyleSheet.create({
  buttonBase: {
    minHeight: 54,
    borderRadius: radius.large,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
    paddingHorizontal: spacing.lg,
  },
  buttonPressed: {
    opacity: 0.9,
    transform: [{ scale: 0.98 }],
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  buttonIcon: {
    marginRight: spacing.sm,
  },
  buttonLabelPrimary: {
    color: colors.white,
  } satisfies TextStyle,
  buttonLabelSecondary: {
    color: colors.brand,
  } satisfies TextStyle,
  secondaryButton: {
    backgroundColor: colors.surfaceElevated,
    borderWidth: 1,
    borderColor: colors.brand,
  },
  destructiveButton: {
    backgroundColor: colors.danger,
  },
  card: {
    backgroundColor: colors.surfaceElevated,
    borderRadius: radius.medium,
    padding: spacing.md,
  },
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    backgroundColor: colors.brandMuted + '66',
    borderRadius: radius.pill,
    alignSelf: 'flex-start',
  },
  badgeText: {
    color: colors.brand,
    fontWeight: '600',
  },
  priceTag: {
    alignItems: 'center',
    gap: spacing.xs,
  },
});
