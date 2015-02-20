{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ExistentialQuantification #-}

module BSP.Tests.Platforms
  ( testPlatformParser
  , ColoredLEDs(..)
  , TestUART(..)
  , TestSPI(..)
  , TestI2C(..)
  , TestCAN(..)
  , TestPlatform(..)
  , testplatform_clockconfig
  , px4fmuv17
  , px4fmuv17_ioar
  , f4discovery
  , open407vc
  ) where

import Ivory.Tower.Config
import Data.Char (toUpper)

import qualified Ivory.BSP.STM32F405.CAN         as F405
import qualified Ivory.BSP.STM32F405.UART        as F405
import qualified Ivory.BSP.STM32F405.GPIO        as F405
import qualified Ivory.BSP.STM32F405.GPIO.AF     as F405
import qualified Ivory.BSP.STM32F405.SPI         as F405
import qualified Ivory.BSP.STM32F405.I2C         as F405

import qualified Ivory.BSP.STM32F427.CAN         as F427
import qualified Ivory.BSP.STM32F427.UART        as F427
import qualified Ivory.BSP.STM32F427.GPIO        as F427
import qualified Ivory.BSP.STM32F427.GPIO.AF     as F427
import qualified Ivory.BSP.STM32F427.SPI         as F427
import qualified Ivory.BSP.STM32F427.I2C         as F427

import Ivory.BSP.STM32.Peripheral.CAN
import Ivory.BSP.STM32.Peripheral.GPIOF4
import Ivory.BSP.STM32.Peripheral.UART
import Ivory.BSP.STM32.Peripheral.SPI hiding (ActiveHigh, ActiveLow)
import Ivory.BSP.STM32.Peripheral.I2C
import Ivory.BSP.STM32.ClockConfig
import Ivory.OS.FreeRTOS.Tower.STM32.Config

import BSP.Tests.LED

testPlatformParser :: ConfigParser TestPlatform
testPlatformParser = do
  p <- subsection "args" $ subsection "platform" string
  case map toUpper p of
    "PX4FMUV17"       -> return px4fmuv17
    "PX4FMUV17_IOAR"  -> return px4fmuv17_ioar
    "F4DISCOVERY"     -> return f4discovery
    "OPEN407VC"       -> return open407vc
    "PORT407Z"        -> return port407z
    "PX4FMUV24"       -> return px4fmuv24
    _ -> fail ("no such platform " ++ p)

data ColoredLEDs =
  ColoredLEDs
    { redLED  :: LED
    , blueLED :: LED
    }

data TestUART =
  TestUART
    { testUARTPeriph :: UART
    , testUARTPins   :: UARTPins
    }

data TestSPI =
  TestSPI
    { testSPIPeriph :: SPIPeriph
    , testSPIPins   :: SPIPins
    }

data TestI2C =
  TestI2C
    { testI2C :: I2CPeriph
    , testSDA :: GPIOPin
    , testSCL :: GPIOPin
    }

data TestCAN =
  TestCAN
    { testCAN        :: CANPeriph
    , testCANRX      :: GPIOPin
    , testCANTX      :: GPIOPin
    , testCANFilters :: CANPeriphFilters
    }


data TestPlatform =
  TestPlatform
    { testplatform_leds  :: ColoredLEDs
    , testplatform_uart  :: TestUART
    , testplatform_spi   :: TestSPI
    , testplatform_i2c   :: TestI2C
    , testplatform_can   :: TestCAN
    , testplatform_stm32 :: STM32Config
    }

testplatform_clockconfig :: TestPlatform -> ClockConfig
testplatform_clockconfig = stm32config_clock . testplatform_stm32

---------- PX4FMUv17 ----------------------------------------------------------

px4fmuv17 :: TestPlatform
px4fmuv17 = TestPlatform
  { testplatform_leds = ColoredLEDs
      { redLED  = LED F405.pinB14 ActiveLow
      , blueLED = LED F405.pinB15 ActiveLow
      }
  , testplatform_uart = TestUART
      { testUARTPeriph = F405.uart5
      , testUARTPins   = UARTPins
          { uartPinTx = F405.pinC12
          , uartPinRx = F405.pinD2
          , uartPinAF = F405.gpio_af_uart5
          }
      }
  , testplatform_spi = TestSPI
      { testSPIPeriph = F405.spi3
      , testSPIPins   = spi3_pins
      }
  , testplatform_i2c = TestI2C
      { testI2C = F405.i2c1
      , testSDA = F405.pinB6
      , testSCL = F405.pinB7
      }
  , testplatform_can = TestCAN
      { testCAN = F405.can1
      , testCANRX = F405.pinD0
      , testCANTX = F405.pinD1
      , testCANFilters = F405.canFilters
      }
  , testplatform_stm32 = stm32f405Defaults 24
  }

-- On IOAR carrier board, we use the FTDI style pinout, attached to uart1.
px4fmuv17_ioar :: TestPlatform
px4fmuv17_ioar = px4fmuv17
  { testplatform_uart = TestUART
    { testUARTPeriph = F405.uart1
    , testUARTPins = UARTPins
          { uartPinTx = F405.pinB6
          , uartPinRx = F405.pinB7
          , uartPinAF = F405.gpio_af_uart1
          }
    }
  }

---------- F4Discovery --------------------------------------------------------

f4discovery :: TestPlatform
f4discovery = TestPlatform
  { testplatform_leds = ColoredLEDs
      { redLED  = LED F405.pinD14 ActiveHigh
      , blueLED = LED F405.pinD15 ActiveHigh
      }
  , testplatform_uart = TestUART
      { testUARTPeriph = F405.uart1
      , testUARTPins = UARTPins
          { uartPinTx = F405.pinB6
          , uartPinRx = F405.pinB7
          , uartPinAF = F405.gpio_af_uart1
          }
      }
  , testplatform_spi = TestSPI
      { testSPIPeriph = F405.spi3
      , testSPIPins   = spi3_pins
      }
  , testplatform_i2c = TestI2C
      { testI2C = F405.i2c1
      , testSDA = F405.pinB6
      , testSCL = F405.pinB7
      }
  , testplatform_can = TestCAN
      { testCAN = F405.can1
      , testCANRX = F405.pinD0
      , testCANTX = F405.pinD1
      , testCANFilters = F405.canFilters
      }
  , testplatform_stm32 = stm32f405Defaults 8
  }

---------- Open407VC ----------------------------------------------------------

open407vc :: TestPlatform
open407vc = TestPlatform
  { testplatform_leds = ColoredLEDs
      { redLED  = LED F405.pinD12 ActiveHigh
      , blueLED = LED F405.pinD13 ActiveHigh
      }
  , testplatform_uart = TestUART
      { testUARTPeriph = F405.uart2
      , testUARTPins = UARTPins
          { uartPinTx = F405.pinA2
          , uartPinRx = F405.pinA3
          , uartPinAF = F405.gpio_af_uart2
          }
      }
  , testplatform_spi = TestSPI
      { testSPIPeriph = F405.spi3
      , testSPIPins   = spi3_pins
      }
  , testplatform_i2c = TestI2C
      { testI2C = F405.i2c1
      , testSDA = F405.pinB6
      , testSCL = F405.pinB7
      }
  , testplatform_can = TestCAN
      { testCAN = F405.can1
      , testCANRX = F405.pinD0
      , testCANTX = F405.pinD1
      , testCANFilters = F405.canFilters
      }
  , testplatform_stm32 = stm32f405Defaults 8
  }


---------- Port407Z -----------------------------------------------------------

port407z :: TestPlatform
port407z = TestPlatform
  { testplatform_leds = ColoredLEDs
      { redLED  = LED F405.pinA4 ActiveHigh -- LED1
      , blueLED = LED F405.pinA5 ActiveHigh -- LED2
      }
  , testplatform_uart = TestUART
      { testUARTPeriph = F405.uart2
      , testUARTPins = UARTPins
          { uartPinTx = F405.pinA2
          , uartPinRx = F405.pinA3
          , uartPinAF = F405.gpio_af_uart2
          }
      }
  , testplatform_spi = TestSPI
      { testSPIPeriph = F405.spi3
      , testSPIPins   = spi3_pins
      }
  , testplatform_i2c = TestI2C
      { testI2C = F405.i2c1
      , testSDA = F405.pinB6
      , testSCL = F405.pinB7
      }
  , testplatform_can = TestCAN
      { testCAN = F405.can1
      , testCANRX = F405.pinD0
      , testCANTX = F405.pinD1
      , testCANFilters = F405.canFilters
      }
  , testplatform_stm32 = stm32f405Defaults 8
  }

spi3_pins :: SPIPins
spi3_pins = SPIPins
  { spiPinMiso = F405.pinC12
  , spiPinMosi = F405.pinC11
  , spiPinSck  = F405.pinC10
  , spiPinAF   = F405.gpio_af_spi3
  }

---------- PX4FMU v 2.4 (Pixhawk main processor) -----------

-- XXX FIX THIS: all these pin, peripheral mappings are
-- wrong, its just a placeholder while we sort out the types
px4fmuv24 :: TestPlatform
px4fmuv24 = TestPlatform
  { testplatform_leds = ColoredLEDs
      { redLED  = LED F427.pinA4 ActiveHigh
      , blueLED = LED F427.pinA5 ActiveHigh
      }
  , testplatform_uart = TestUART
      { testUARTPeriph = F427.uart2
      , testUARTPins = UARTPins
          { uartPinTx = F427.pinA2
          , uartPinRx = F427.pinA3
          , uartPinAF = F427.gpio_af_uart2
          }
      }
  , testplatform_spi = TestSPI
      { testSPIPeriph = F427.spi3
      , testSPIPins   = spi3_pins
      }
  , testplatform_i2c = TestI2C
      { testI2C = F427.i2c1
      , testSDA = F427.pinB6
      , testSCL = F427.pinB7
      }
  , testplatform_can = TestCAN
      { testCAN = F427.can1
      , testCANRX = F427.pinD0
      , testCANTX = F427.pinD1
      , testCANFilters = F427.canFilters
      }
  , testplatform_stm32 = stm32f427Defaults 8
  }

