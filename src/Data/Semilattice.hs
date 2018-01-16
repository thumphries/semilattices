{-# LANGUAGE DeriveDataTypeable, DeriveGeneric, DeriveTraversable, GeneralizedNewtypeDeriving #-}
module Data.Semilattice where

import Control.Applicative
import Control.Monad.Fix
import Data.Coerce
import Data.Data
import qualified Data.Semigroup as Semigroup
import qualified Data.Set as Set
import GHC.Generics

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
  --   Additionally, if @s@ has a 'LowerBound', the identity law must hold:
  --
  --   > bottom \/ a = a
  (\/) :: s -> s -> s

  infixr 6 \/

class Meet s where
  -- | The meet operation.
  --
  --   Laws:
  --
  --   Idempotence:
  --
  --   > x /\ x = x
  --
  --   Associativity:
  --
  --   > a /\ (b /\ c) = (a /\ b) /\ c
  --
  --   Commutativity:
  --
  --   > a /\ b = b /\ a
  --
  --   Additionally, if @s@ has an 'UpperBound', the identity law must hold:
  --
  --   > top /\ a = a
  (/\) :: s -> s -> s

  infixr 7 /\

class LowerBound s where
  -- | The greatest lower bound of @s@.
  --
  --   Laws:
  --
  --   If @s@ is 'Bounded', we require 'bottom' and 'minBound' to agree:
  --
  --   > bottom = minBound
  --
  --   If @s@ is a 'Join', 'bottom' must be the identity of '(\/)':
  --
  --   > bottom \/ a = a
  --
  --   If @s@ is 'Ord'ered, 'bottom' must be at least as small as every terminating value:
  --
  --   > compare bottom a /= GT
  bottom :: s

class UpperBound s where
  -- | The least upper bound of @s@.
  --
  --   Laws:
  --
  --   If @s@ is 'Bounded', we require 'top' and 'maxBound' to agree:
  --
  --   > top = maxBound
  --
  --   If @s@ is a 'Meet', 'top' must be the identity of '(/\)':
  --
  --   > top \/ a = a
  --
  --   If @s@ is 'Ord'ered, 'top' must be at least as large as every terminating value:
  --
  --   > compare top a /= LT
  top :: s


instance Join () where
  _ \/ _ = ()

instance Meet () where
  _ /\ _ = ()

instance LowerBound () where
  bottom = ()

instance UpperBound () where
  top = ()


instance Join Bool where
  (\/) = (||)

instance Meet Bool where
  (/\) = (&&)

instance LowerBound Bool where
  bottom = False

instance UpperBound Bool where
  top = True


instance Ord a => Join (Semigroup.Max a) where
  (\/) = (Semigroup.<>)

instance Bounded a => LowerBound (Semigroup.Max a) where
  bottom = minBound


instance Ord a => Meet (Semigroup.Min a) where
  (/\) = (Semigroup.<>)

instance Bounded a => UpperBound (Semigroup.Min a) where
  top = maxBound


instance Ord a => Join (Set.Set a) where
  (\/) = Set.union

instance Ord a => Meet (Set.Set a) where
  (/\) = Set.intersection

instance LowerBound (Set.Set a) where
  bottom = Set.empty


newtype Tumble a = Tumble { getTumble :: a }
  deriving (Bounded, Data, Enum, Eq, Foldable, Functor, Generic, Generic1, Num, Ord, Read, Show, Traversable)

instance Applicative Tumble where
  pure = Tumble
  a <* _ = a
  _ *> a = a
  (<*>) = coerce
  liftA2 = coerce

instance Monad Tumble where
  (>>) = (*>)
  Tumble a >>= f = f a

instance MonadFix Tumble where
  mfix f = fix (f . getTumble)

instance Join a => Meet (Tumble a) where
  Tumble a /\ Tumble b = Tumble (a \/ b)

instance Meet a => Join (Tumble a) where
  Tumble a \/ Tumble b = Tumble (a /\ b)

instance LowerBound a => UpperBound (Tumble a) where
  top = Tumble bottom

instance UpperBound a => LowerBound (Tumble a) where
  bottom = Tumble top
