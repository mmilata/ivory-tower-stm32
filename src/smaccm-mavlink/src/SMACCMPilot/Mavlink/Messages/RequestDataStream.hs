{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavgen_ivory.py

module SMACCMPilot.Mavlink.Messages.RequestDataStream where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send
import qualified SMACCMPilot.Communications as Comm

import Ivory.Language
import Ivory.Stdlib

requestDataStreamMsgId :: Uint8
requestDataStreamMsgId = 66

requestDataStreamCrcExtra :: Uint8
requestDataStreamCrcExtra = 148

requestDataStreamModule :: Module
requestDataStreamModule = package "mavlink_request_data_stream_msg" $ do
  depend packModule
  depend mavlinkSendModule
  incl mkRequestDataStreamSender
  incl requestDataStreamUnpack
  defStruct (Proxy :: Proxy "request_data_stream_msg")

[ivory|
struct request_data_stream_msg
  { req_message_rate :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  ; req_stream_id :: Stored Uint8
  ; start_stop :: Stored Uint8
  }
|]

mkRequestDataStreamSender ::
  Def ('[ ConstRef s0 (Struct "request_data_stream_msg")
        , Ref s1 (Stored Uint8) -- seqNum
        , Ref s1 Comm.MAVLinkArray -- tx buffer
        ] :-> ())
mkRequestDataStreamSender =
  proc "mavlink_request_data_stream_msg_send"
  $ \msg seqNum sendArr -> body
  $ do
  arr <- local (iarray [] :: Init (Array 6 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> req_message_rate)
  call_ pack buf 2 =<< deref (msg ~> target_system)
  call_ pack buf 3 =<< deref (msg ~> target_component)
  call_ pack buf 4 =<< deref (msg ~> req_stream_id)
  call_ pack buf 5 =<< deref (msg ~> start_stop)
  -- 6: header len, 2: CRC len
  let usedLen = 6 + 6 + 2 :: Integer
  let sendArrLen = arrayLen sendArr
  if sendArrLen < usedLen
    then error "requestDataStream payload of length 6 is too large!"
    else do -- Copy, leaving room for the payload
            arrCopy sendArr arr 6
            call_ mavlinkSendWithWriter
                    requestDataStreamMsgId
                    requestDataStreamCrcExtra
                    6
                    seqNum
                    sendArr
            let usedLenIx = fromInteger usedLen
            -- Zero out the unused portion of the array.
            for (fromInteger sendArrLen - usedLenIx) $ \ix ->
              store (sendArr ! (ix + usedLenIx)) 0
            retVoid

instance MavlinkUnpackableMsg "request_data_stream_msg" where
    unpackMsg = ( requestDataStreamUnpack , requestDataStreamMsgId )

requestDataStreamUnpack :: Def ('[ Ref s1 (Struct "request_data_stream_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
requestDataStreamUnpack = proc "mavlink_request_data_stream_unpack" $ \ msg buf -> body $ do
  store (msg ~> req_message_rate) =<< call unpack buf 0
  store (msg ~> target_system) =<< call unpack buf 2
  store (msg ~> target_component) =<< call unpack buf 3
  store (msg ~> req_stream_id) =<< call unpack buf 4
  store (msg ~> start_stop) =<< call unpack buf 5

