{-# LANGUAGE DeriveTraversable, GeneralizedNewtypeDeriving #-}
module Data.Join where

import Data.Lower
import Data.Semigroup
import Data.Set

-- $setup
-- >>> import Data.Upper
-- >>> import Test.QuickCheck

-- | A join semilattice is an idempotent commutative semigroup.
class Join s where
  -- | The join operation.
  --
  --   Laws:
  --
  --   Idempotence:
  --
  --   > x \/ x = x
  --
  --   Associativity:
  --
  --   > a \/ (b \/ c) = (a \/ b) \/ c
  --
  --   Commutativity:
  --
  --   > a \/ b = b \/ a
  --
  --   Additionally, if @s@ has a 'Lower' bound, then 'bottom' must be its left- and right-identity:
  --
  --   > bottom \/ a = a
  --   > a \/ bottom = a
  --
  --   If @s@ has an 'Upper' bound, then 'top' must be its left- and right-annihilator:
  --
  --   > top \/ a = top
  --   > a \/ top = top
  (\/) :: s -> s -> s

  infixr 6 \/


instance Join () where
  _ \/ _ = ()

-- | Boolean disjunction forms a semilattice.
--
--   Idempotence:
--   prop> \ x -> x \/ x == (x :: Bool)
--
--   Associativity:
--   prop> \ a b c -> a \/ (b \/ c) == (a \/ b) \/ (c :: Bool)
--
--   Commutativity:
--   prop> \ a b -> a \/ b == b \/ (a :: Bool)
--
--   Identity:
--   prop> \ a -> bottom \/ a == (a :: Bool)
--
--   Absorption:
--   prop> \ a -> top \/ a == (top :: Bool)
instance Join Bool where
  (\/) = (||)

instance Ord a => Join (Max a) where
  (\/) = (<>)

-- | Set union forms a semilattice.
--
--   Idempotence:
--   prop> \ x -> x \/ x == (x :: Set Char)
--
--   Associativity:
--   prop> \ a b c -> a \/ (b \/ c) == (a \/ b) \/ (c :: Set Char)
--
--   Commutativity:
--   prop> \ a b -> a \/ b == b \/ (a :: Set Char)
--
--   Identity:
--   prop> \ a -> bottom \/ a == (a :: Set Char)
instance Ord a => Join (Set a) where
  (\/) = union


newtype Joining a = Joining { getJoining :: a }
  deriving (Enum, Eq, Foldable, Functor, Join, Lower, Num, Ord, Read, Show, Traversable)

instance Join a => Semigroup (Joining a) where
  (<>) = (\/)

instance (Lower a, Join a) => Monoid (Joining a) where
  mappend = (<>)
  mempty = bottom
