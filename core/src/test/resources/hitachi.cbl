******************************************************************
**    All Rights Reserved. Copyright (C) 2004, Hitachi, Ltd. P-1M64-2A1
**    目的        :   TP1/EE サンプルプログラム(COBOL言語版)
******************************************************************
* spp.cbl
******************************************************************
**    目的        :   サービストランザクション処理（非応答型RPC用）
**    機能        :   サービストランザクション処理の実行
**             (1)受信データから取得する情報を格納するデータ領域を確保する
**             (2)受信データから、必要な情報を取得する
**             (3)データ領域を用いて、タイマトランザクションを発行
**             (4)確保した領域の解放
**             (5)タイマトランザクション失敗時には、ロールバックする
**
**                入力データ形式
**                +----------------------------------------------+
**                | データ名  | データ型   | 意味                |
**                |==============================================|
**                | NAM-LEN   | PIC S9(9)  | 名前の文字列長      |
**                |----------------------------------------------|
**                | NAM-ARG   | PIC X(20)  | 名前                |
**                |----------------------------------------------|
**                | SEX-LEN   | PIC S9(9)  | 性別の文字列長      |
**                |----------------------------------------------|
**                | SEX-ARG   | PIC X(4)   | 性別                |
**                |----------------------------------------------|
**                | AGE-LEN   | PIC S9(9)  | 年齢の文字列長      |
**                |----------------------------------------------|
**                | AGE-ARG   | PIC X(4)   | 年齢                |
**                |----------------------------------------------|
**                | SALE-ARG  | PIC S9(9)  | 売上                |
**                +----------------------------------------------+
**
**                トランザクション処理に必要な情報
**                +----------------------------------------------+
**                | データ名  | データ型   | 意味                |
**                |==============================================|
**                | NAM-ARG   | PIC X(20)  | 名前                |
**                |----------------------------------------------|
**                | SEX-ARG   | PIC X(4)   | 性別                |
**                |----------------------------------------------|
**                | AGE-ARG   | PIC X(4)   | 年齢                |
**                |----------------------------------------------|
**                | SALE-ARG  | PIC S9(9)  | 売上                |
**                |----------------------------------------------|
**                | SRV-ARG   | PIC X(32)  | サービス名          |
**                +----------------------------------------------+
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_UAP.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** 送信データ使用変数 ********************************
*** 引数(IN-DATA)情報格納構造体
 01 SQL-ARG1.
     02  NAM-LEN    PIC S9(9) COMP.
     02  NAM-ARG    PIC X(20).
     02  SEX-LEN    PIC S9(9) COMP.
     02  SEX-ARG    PIC X(4).
     02  AGE-LEN    PIC S9(9) COMP.
     02  AGE-ARG    PIC X(4).
     02  SALE-ARG   PIC S9(9) COMP.
*** 送信データ構造体
 01 SQL-ARG2.
     02  NAM-ARG    PIC X(20).
     02  SEX-ARG    PIC X(4).
     02  AGE-ARG    PIC X(4).
     02  SALE-ARG   PIC S9(9) COMP.
     02  SRV-ARG    PIC X(32).
*
*** LOGPRINTメッセージ設定 *********************
 01 PGMID         PIC X(3) VALUE 'SP '.
***  サンプルメッセージ(領域確保失敗)
 01 MSGID52       PIC X(12) VALUE 'KFSB05200-E '.
 01 MSG52         PIC X(64) VALUE
        'SERVER:領域確保に失敗しました。'.
 01 MSGLEN52      PIC 9(9)  COMP VALUE 64.
***  サンプルメッセージ(タイマトラン起動失敗)
 01 MSGID53       PIC X(12) VALUE 'KFSB05300-E '.
 01 MSG53         PIC X(128) VALUE
        'SERVER:タイマトランザクション起動に失敗しました。'.
 01 MSGLEN53      PIC 9(9)  COMP VALUE 128.
***  サンプルメッセージ(ロールバック失敗)
 01 MSGID54       PIC X(12) VALUE 'KFSB05400-E '.
 01 MSG54         PIC X(64) VALUE
        'SERVER:ROLLBACKに失敗しました。'.
 01 MSGLEN54      PIC 9(9)  COMP VALUE 64.
***  サンプルメッセージ(DBキュー書込み失敗)
 01 MSGID55       PIC X(12) VALUE 'KFSB06000-E '.
 01 MSG55         PIC X(128) VALUE
        'SERVER:DBキューのメッセージ書込みに失敗しました。'.
 01 MSGLEN55      PIC 9(9)  COMP VALUE 128.
*
*** API各種引数設定 ****************************
***  CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
***  CBLEETRN('C-ROLL  ')
 01 EETRN-C-ROLL-ARG.
     02 EETRN-C-ROLL-REQUEST      PIC X(8) VALUE 'C-ROLL  '.
     02 EETRN-C-ROLL-STATUS-CODE  PIC X(5).
     02 FILLER                    PIC X(3).
     02 EETRN-C-ROLL-THKIND       PIC X(4) VALUE 'KILL'.
     02 EETRN-C-ROLL-ECODE        PIC S9(9) COMP.
*
***  CBLEEMEM('GETWK   ')
 01 EEMEM-GETWK-ARG1.
     02 EEMEM-GETWK-REQUEST       PIC X(8) VALUE 'GETWK   '.
     02 EEMEM-GETWK-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EEMEM-GETWK-FLAGS         PIC S9(9) COMP VALUE ZERO.
 01 EEMEM-GETWK-ARG2.
     02 EEMEM-GETWK-SEG-TYPE      PIC X(1) VALUE 'U'.
     02 FILLER                    PIC X(3).
     02 EEMEM-GETWK-SEG-SIZE      PIC 9(9) COMP VALUE 128.
     02 EEMEM-GETWK-SEG-PT        ADDRESS.
*
***  CBLEEMEM('RLSWK   ')
 01 EEMEM-RLSWK-ARG1.
     02 EEMEM-RLSWK-REQUEST       PIC X(8) VALUE 'RLSWK   '.
     02 EEMEM-RLSWK-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EEMEM-RLSWK-FLAGS         PIC S9(9) COMP VALUE ZERO.
 01 EEMEM-RLSWK-ARG2.
     02 EEMEM-RLSWK-SEG-PT        ADDRESS.
*
***  CBLEETIM('EXECAP  ')
 01 EETIM-EXECAP-ARG1.
     02 EETIM-EXECAP-REQUEST      PIC X(8) VALUE 'EXECAP  '.
     02 EETIM-EXECAP-STATUS-CODE  PIC X(5).
     02 FILLER                    PIC X(3).
     02 EETIM-EXECAP-FLAGS        PIC S9(9) COMP VALUE 0.
 01 EETIM-EXECAP-ARG2.
     02 EETIM-EXECAP-ACTTYPE      PIC X(4) VALUE 'INST'.
     02 EETIM-EXECAP-ACTION       PIC X(4) VALUE 'INTV'.
     02 EETIM-EXECAP-ACTIVE       PIC 9(9) COMP VALUE 10.
     02 EETIM-EXECAP-REQID        PIC 9(9) COMP VALUE 0.
     02 EETIM-EXECAP-SERVICE      PIC X(32) VALUE 'srv02 '.
     02 EETIM-EXECAP-PRIORITY     PIC X(4) VALUE 'HI  '.
 01 EETIM-EXECAP-ARG3 ADDRESSED BY TIM-PT.
     02 EETIM-EXECAP-DATA_LEN     PIC 9(9) COMP.
     02 EETIM-EXECAP-DATA         PIC X(64).
*
***  CBLEEDBQ('MSGPUT  ')
 01 EEDBQ-MSGPUT-ARG1.
     02 EEDBQ-MSGPUT-REQUEST      PIC X(8) VALUE 'MSGPUT  '.
     02 EEDBQ-MSGPUT-STATUS-CODE  PIC X(5).
     02 FILLER                    PIC X(3).
     02 EEDBQ-MSGPUT-FLAGS        PIC S9(9).
     02 EEDBQ-MSGPUT-DBQNAME      PIC X(32) VALUE 'DBQ001'.
 01 EEDBQ-MSGPUT-ARG2.
     02 EEDBQ-MSGPUT-DATA_LEN     PIC 9(9) COMP.
     02 EEDBQ-MSGPUT-DATA         PIC X(128).
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
************************************************
*   IN-DATAをタイマトラン送信用データに変更
************************************************
 MOVE IN-DATA TO SQL-ARG1.
*
 MOVE NAM-ARG OF SQL-ARG1 (1:NAM-LEN OF SQL-ARG1)
     TO NAM-ARG OF SQL-ARG2.
 MOVE SEX-ARG OF SQL-ARG1 (1:SEX-LEN OF SQL-ARG1)
     TO SEX-ARG  OF SQL-ARG2.
 MOVE AGE-ARG OF SQL-ARG1 (1:AGE-LEN OF SQL-ARG1)
     TO AGE-ARG  OF SQL-ARG2.
 MOVE SALE-ARG OF SQL-ARG1 TO SALE-ARG OF SQL-ARG2.
 MOVE SERVICE_NAME OF EERPC_INTERFACE_TBL
     (1:SERVICE_LEN OF EERPC_INTERFACE_TBL)
         TO SRV-ARG OF SQL-ARG2 .
*
************************************************
*   GETWKを発行してタイマトラン送信用の領域を確保
************************************************
*** GETWK発行
 CALL 'CBLEEMEM'
     USING EEMEM-GETWK-ARG1 EEMEM-GETWK-ARG2.
*** GETWK成否判定
   IF EEMEM-GETWK-STATUS-CODE OF EEMEM-GETWK-ARG1
      NOT = EE_OK THEN
************************************************
*   GETWK失敗
************************************************
*** 領域確保失敗メッセージの表示
*** LOGPRINT引数設定
   MOVE PGMID     TO
       EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
   MOVE MSGID52   TO
       EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
   MOVE MSG52     TO
       EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
   MOVE MSGLEN52  TO
       EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
   CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
       EELOG-PRINT-ARG3
   GO TO MN-END
   END-IF.
*
************************************************
*   GETWK成功>確保した領域を用い送信データを設定
************************************************
*** アドレス受け渡し
 COMPUTE TIM-PT = EEMEM-GETWK-SEG-PT OF EEMEM-GETWK-ARG2.
*** 送信DATA設定
 MOVE 64 TO EETIM-EXECAP-DATA_LEN OF EETIM-EXECAP-ARG3.
 MOVE SQL-ARG2 TO EETIM-EXECAP-DATA OF EETIM-EXECAP-ARG3.
*
************************************************
*   EXECAP発行
************************************************
 CALL 'CBLEETIM' USING EETIM-EXECAP-ARG1
    EETIM-EXECAP-ARG2 EETIM-EXECAP-ARG3.
************************************************
*   RLSWK発行(確保領域の解放)
************************************************
*** 解放する領域の設定
 COMPUTE EEMEM-RLSWK-SEG-PT OF EEMEM-RLSWK-ARG2
     = EEMEM-GETWK-SEG-PT OF EEMEM-GETWK-ARG2.
*** RLSWK発行
 CALL 'CBLEEMEM'
     USING EEMEM-RLSWK-ARG1 EEMEM-RLSWK-ARG2.
*
************************************************
*   EXECAP成否判定
************************************************
   IF EETIM-EXECAP-STATUS-CODE OF EETIM-EXECAP-ARG1
       NOT = EE_OK THEN
************************************************
*   EXECAP:失敗>LOG出力/ROLLBACK発行
************************************************
*** タイマトラン失敗メッセージの表示
*** LOGPRINT引数設定
   MOVE PGMID     TO
       EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
   MOVE MSGID53   TO
       EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
   MOVE MSG53     TO
       EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
   MOVE MSGLEN53  TO
       EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
   CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
       EELOG-PRINT-ARG3
   END-CALL
*
*** ROLLBACK(KILL)発行
   CALL 'CBLEETRN' USING EETRN-C-ROLL-ARG
*** ROLLBACK成否判定
     IF EETRN-C-ROLL-STATUS-CODE OF EETRN-C-ROLL-ARG
         NOT = EE_OK THEN
************************************************
*   ROLLBACK失敗
************************************************
*** ロールバック失敗メッセージの表示
*** LOGPRINT引数設定
     MOVE PGMID     TO
         EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
     MOVE MSGID54   TO
         EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
     MOVE MSG54     TO
         EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
     MOVE MSGLEN54  TO
         EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
     CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
         EELOG-PRINT-ARG3
     END-IF
   GO TO MN-END
   END-IF.
*
*** 送信DATA設定
MOVE 0 TO EEDBQ-MSGPUT-FLAGS OF EEDBQ-MSGPUT-ARG1.
 MOVE 124 TO EEDBQ-MSGPUT-DATA_LEN OF EEDBQ-MSGPUT-ARG2.
 MOVE IN-DATA TO EEDBQ-MSGPUT-DATA OF EEDBQ-MSGPUT-ARG2.
*** MSGPUT発行
 CALL 'CBLEEDBQ'
     USING EEDBQ-MSGPUT-ARG1 EEDBQ-MSGPUT-ARG2.
*
************************************************
*   MSGPUT成否判定
************************************************
   IF EEDBQ-MSGPUT-STATUS-CODE OF EEDBQ-MSGPUT-ARG1
       NOT = EE_OK THEN
************************************************
*   MSGPUT:失敗>LOG出力/ROLLBACK発行
************************************************
*** タイマトラン失敗メッセージの表示
*** LOGPRINT引数設定
   MOVE PGMID     TO
       EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
   MOVE MSGID55   TO
       EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
   MOVE MSG55     TO
       EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
   MOVE MSGLEN55  TO
       EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
   CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
       EELOG-PRINT-ARG3
   END-CALL
*
*** ROLLBACK(KILL)発行
   CALL 'CBLEETRN' USING EETRN-C-ROLL-ARG
*** ROLLBACK成否判定
     IF EETRN-C-ROLL-STATUS-CODE OF EETRN-C-ROLL-ARG
         NOT = EE_OK THEN
************************************************
*   ROLLBACK失敗
************************************************
*** ロールバック失敗メッセージの表示
*** LOGPRINT引数設定
     MOVE PGMID     TO
         EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
     MOVE MSGID54   TO
         EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
     MOVE MSG54     TO
         EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
     MOVE MSGLEN54  TO
         EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
     CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
         EELOG-PRINT-ARG3
     END-IF
  END-IF.
*
 MN-END.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_UAP.
*
*
******************************************************************
**    目的        :   エラートランザクション1処理
**    機能        :   エラートランザクション1処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_E1.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID56       PIC X(12) VALUE 'KFSB05600-E '.
 01 MSG56         PIC X(64) VALUE
        'SERVER:エラートランザクション1を起動します。'.
 01 MSGLEN56      PIC 9(9)  COMP VALUE 64.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID56   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG56     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN56  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_E1.
*
******************************************************************
**    目的        :   エラートランザクション2処理
**    機能        :   エラートランザクション2処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_E2.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID57       PIC X(12) VALUE 'KFSB05700-E '.
 01 MSG57         PIC X(64) VALUE
        'SERVER:エラートランザクション2を起動します。'.
 01 MSGLEN57      PIC 9(9)  COMP VALUE 64.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
************************************************
*   引数宣言
************************************************
       LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID57   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG57     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN57  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_E2.
*
******************************************************************
**    目的        :   エラートランザクション3処理
**    機能        :   エラートランザクション3処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_E3.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID58       PIC X(12) VALUE 'KFSB05800-E '.
 01 MSG58         PIC X(64) VALUE
         'SERVER:エラートランザクション3を起動します。'.
 01 MSGLEN58      PIC 9(9)  COMP VALUE 64.
*** サンプルメッセージ(RPC処理失敗)
 01 MSGID55       PIC X(12) VALUE 'KFSB05500-E '.
 01 MSG55         PIC X(64) VALUE
         'SERVER:RPC処理に失敗しました。'.
 01 MSGLEN55      PIC 9(9)  COMP VALUE 64.
*
*** RPC設定 *****************************v0101**
 01 RPC-FLAGS        PIC S9(9) COMP VALUE 0.
 01 RPC-SVNAME       PIC X(32) VALUE 'outSRV '.
 01 RPC-SVGROUP      PIC X(32) VALUE 'outSPP '.
 01 RPC-OUTDATALEN   PIC 9(9)  COMP VALUE 8.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
*** CBLEERPC('CALL    ')
 01 EERPC-CALL-ARG1.
     02 EERPC-CALL-REQUEST        PIC X(8) VALUE 'CALL    '.
     02 EERPC-CALL-STATUS-CODE    PIC X(5).
     02 FILLER                    PIC X(3).
     02 EERPC-CALL-FLAGS          PIC S9(9) COMP VALUE ZERO.
     02 EERPC-CALL-DESCRIPTOR     PIC S9(9) COMP.
     02 EERPC-CALL-SVNAME         PIC X(32).
     02 EERPC-CALL-SVGROUP        PIC X(32).
 01 EERPC-CALL-ARG2.
     02 EERPC-CALL-INDATALEN      PIC 9(9) COMP.
     02 EERPC-CALL-INDATA         PIC X(128).
 01 EERPC-CALL-ARG3.
     02 EERPC-CALL-OUTDATALEN     PIC 9(9) COMP.
     02 EERPC-CALL-OUTDATA        PIC X(8).
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
    USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID58   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG58     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN58  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
************************************************
*   RPC送信
************************************************
*** RPC送信データの設定
 MOVE ARG-INDATA OF IN-DATA TO
     EERPC-CALL-INDATA OF EERPC-CALL-ARG2.
 MOVE ARG-INLEN OF IN-LEN TO
     EERPC-CALL-INDATALEN  OF EERPC-CALL-ARG2.
 MOVE RPC-FLAGS      TO EERPC-CALL-FLAGS      OF EERPC-CALL-ARG1.
 MOVE RPC-SVNAME     TO EERPC-CALL-SVNAME     OF EERPC-CALL-ARG1.
 MOVE RPC-SVGROUP    TO EERPC-CALL-SVGROUP    OF EERPC-CALL-ARG1.
 MOVE RPC-OUTDATALEN TO EERPC-CALL-OUTDATALEN OF EERPC-CALL-ARG3.
*** RPC発行
 CALL 'CBLEERPC'
     USING EERPC-CALL-ARG1 EERPC-CALL-ARG2 EERPC-CALL-ARG3.
*** RPC成否判定
   IF EERPC-CALL-STATUS-CODE OF EERPC-CALL-ARG1
       NOT = EE_OK THEN
************************************************
*   RPC送信失敗
************************************************
*** RPC処理失敗メッセージの表示
*** LOGPRINT引数設定
   MOVE PGMID     TO
       EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
   MOVE MSGID55   TO
       EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
   MOVE MSG55     TO
       EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
   MOVE MSGLEN55  TO
       EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
   CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
       EELOG-PRINT-ARG3
   END-IF.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_E3.
*
******************************************************************
**    目的        :   エラートランザクション4処理
**    機能        :   エラートランザクション4処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_E4.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID59       PIC X(12) VALUE 'KFSB05900-E '.
 01 MSG59         PIC X(64) VALUE
        'SERVER:エラートランザクション4を起動します。'.
 01 MSGLEN59      PIC 9(9)  COMP VALUE 64.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID59   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG59     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN59  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_E4.
*
******************************************************************
**    目的        :   初期化トランザクション処理
**    機能        :   初期化トランザクション処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_MI.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID62       PIC X(12) VALUE 'KFSB06200-I '.
 01 MSG62         PIC X(64) VALUE
        'SERVER:サンプルUAPを開始します。'.
 01 MSGLEN62      PIC 9(9)  COMP VALUE 64.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
************************************************
*   引数宣言
************************************************
       LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID62   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG62     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN62  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_MI.
*
******************************************************************
**    目的        :   終了トランザクション
**    機能        :   終了トランザクション処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_ME.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID63       PIC X(12) VALUE 'KFSB06300-I '.
 01 MSG63         PIC X(64) VALUE
         'SERVER:サンプルUAPを終了します。'.
 01 MSGLEN63      PIC 9(9)  COMP VALUE 64.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID63   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG63     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN63  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_ME.
*
******************************************************************
**    目的        :   タイマトランザクション処理
**    機能        :   タイマトランザクション処理を実行
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_TM.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(トラン起動)
 01 MSGID64       PIC X(12) VALUE 'KFSB06400-I '.
 01 MSG64         PIC X(64) VALUE
         'SERVER:タイマトランザクションを起動します。'.
 01 MSGLEN64      PIC 9(9)  COMP VALUE 64.
*
*** サンプルメッセージ(RPC処理失敗)
 01 MSGID55       PIC X(12) VALUE 'KFSB05500-E '.
 01 MSG55         PIC X(64) VALUE
         'SERVER:RPC処理に失敗しました。'.
 01 MSGLEN55      PIC 9(9)  COMP VALUE 64.
*
*** RPC設定 ****************************v0101***
 01 RPC-FLAGS        PIC S9(9) COMP VALUE 0.
 01 RPC-SVNAME       PIC X(32) VALUE 'outSRV '.
 01 RPC-SVGROUP      PIC X(32) VALUE 'outSPP '.
 01 RPC-OUTDATALEN   PIC 9(9)  COMP VALUE 8.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
*** CBLEERPC('CALL    ')
 01 EERPC-CALL-ARG1.
     02 EERPC-CALL-REQUEST        PIC X(8) VALUE 'CALL    '.
     02 EERPC-CALL-STATUS-CODE    PIC X(5).
     02 FILLER                    PIC X(3).
     02 EERPC-CALL-FLAGS          PIC S9(9) COMP VALUE ZERO.
     02 EERPC-CALL-DESCRIPTOR     PIC S9(9) COMP.
     02 EERPC-CALL-SVNAME         PIC X(32).
     02 EERPC-CALL-SVGROUP        PIC X(32).
 01 EERPC-CALL-ARG2.
     02 EERPC-CALL-INDATALEN      PIC 9(9) COMP.
     02 EERPC-CALL-INDATA         PIC X(64).
 01 EERPC-CALL-ARG3.
     02 EERPC-CALL-OUTDATALEN     PIC 9(9) COMP.
     02 EERPC-CALL-OUTDATA        PIC X(8).
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID64   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG64     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN64  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
************************************************
*   RPC送信
************************************************
*** RPC送信データの設定
 MOVE ARG-INDATA OF IN-DATA TO
     EERPC-CALL-INDATA OF EERPC-CALL-ARG2.
 MOVE ARG-INLEN OF IN-LEN TO
     EERPC-CALL-INDATALEN  OF EERPC-CALL-ARG2.
 MOVE RPC-FLAGS      TO EERPC-CALL-FLAGS      OF EERPC-CALL-ARG1.
 MOVE RPC-SVNAME     TO EERPC-CALL-SVNAME     OF EERPC-CALL-ARG1.
 MOVE RPC-SVGROUP    TO EERPC-CALL-SVGROUP    OF EERPC-CALL-ARG1.
 MOVE RPC-OUTDATALEN TO EERPC-CALL-OUTDATALEN OF EERPC-CALL-ARG3.
*** RPC発行
 CALL 'CBLEERPC'
     USING EERPC-CALL-ARG1 EERPC-CALL-ARG2 EERPC-CALL-ARG3.
*** RPC成否判定
   IF EERPC-CALL-STATUS-CODE OF EERPC-CALL-ARG1
       NOT = EE_OK THEN
************************************************
*   RPC送信失敗
************************************************
*** RPC処理失敗メッセージの表示
*** LOGPRINT引数設定
   MOVE PGMID     TO
       EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
   MOVE MSGID55   TO
       EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
   MOVE MSG55     TO
       EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
   MOVE MSGLEN55  TO
       EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
   CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
       EELOG-PRINT-ARG3
   END-IF.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_TM.
*
*
******************************************************************
**    目的        :   DBキューの読出しトランザクション
**    機能        :   DBキューの読出しトランザクションを実行する
******************************************************************
******************************************************************
*   見出し
******************************************************************
 IDENTIFICATION  DIVISION.
*
******************************************************************
*   関数名
******************************************************************
 PROGRAM-ID.     SAMPLE_DBQ.
*
******************************************************************
*   環境部
******************************************************************
 ENVIRONMENT     DIVISION.
*
******************************************************************
*   変数宣言部
******************************************************************
 DATA            DIVISION.
************************************************
*   変数/定数宣言
************************************************
 WORKING-STORAGE SECTION.
*** リターンコード値 ***************************
 01 EE_OK         PIC X(5)  VALUE '00000'.
*
*** LOGPRINT設定 *******************************
 01 PGMID         PIC X(3) VALUE 'SP '.
*
*** サンプルメッセージ(DBQトラン起動)
 01 MSGID65       PIC X(12) VALUE 'KFSB06500-I '.
 01 MSG65         PIC X(128) VALUE
         'SERVER:DBキューの読出しトランザクションを起動します。'.
 01 MSGLEN65      PIC 9(9)  COMP VALUE 128.
*** サンプルメッセージ(RPC処理失敗)
 01 MSGID55       PIC X(12) VALUE 'KFSB05500-E '.
 01 MSG55         PIC X(64) VALUE
         'SERVER:RPC処理に失敗しました。'.
 01 MSGLEN55      PIC 9(9)  COMP VALUE 64.
*
*** RPC設定 ****************************v0101***
 01 RPC-FLAGS        PIC S9(9) COMP VALUE 0.
 01 RPC-SVNAME       PIC X(32) VALUE 'outSRV '.
 01 RPC-SVGROUP      PIC X(32) VALUE 'outSPP '.
 01 RPC-OUTDATALEN   PIC 9(9)  COMP VALUE 8.
*
*** API引数設定 ********************************
*** CBLEELOG('PRINT   ')
 01 EELOG-PRINT-ARG1.
     02 EELOG-PRINT-REQUEST       PIC X(8) VALUE 'PRINT   '.
     02 EELOG-PRINT-STATUS-CODE   PIC X(5).
     02 FILLER                    PIC X(3).
     02 EELOG-PRINT-FLAGS         PIC S9(9) COMP VALUE ZERO.
     02 EELOG-PRINT-MSG-ID        PIC X(12).
     02 EELOG-PRINT-PGM-ID        PIC X(3).
 01 EELOG-PRINT-ARG2.
     02 EELOG-PRINT-MSG-LEN       PIC 9(9) COMP.
     02 EELOG-PRINT-MSG           PIC X(128).
 01 EELOG-PRINT-ARG3.
     02 EELOG-PRINT-INFO          PIC S9(9) COMP VALUE ZERO.
*
*** CBLEERPC('CALL    ')
 01 EERPC-CALL-ARG1.
     02 EERPC-CALL-REQUEST        PIC X(8) VALUE 'CALL    '.
     02 EERPC-CALL-STATUS-CODE    PIC X(5).
     02 FILLER                    PIC X(3).
     02 EERPC-CALL-FLAGS          PIC S9(9) COMP VALUE ZERO.
     02 EERPC-CALL-DESCRIPTOR     PIC S9(9) COMP.
     02 EERPC-CALL-SVNAME         PIC X(32).
     02 EERPC-CALL-SVGROUP        PIC X(32).
 01 EERPC-CALL-ARG2.
     02 EERPC-CALL-INDATALEN      PIC 9(9) COMP.
     02 EERPC-CALL-INDATA         PIC X(64).
 01 EERPC-CALL-ARG3.
     02 EERPC-CALL-OUTDATALEN     PIC 9(9) COMP.
     02 EERPC-CALL-OUTDATA        PIC X(8).
*
************************************************
*   引数宣言
************************************************
 LINKAGE SECTION.
*
 01 IN-DATA.
     02 ARG-INDATA   PIC X(128).
 01 IN-LEN.
     02 ARG-INLEN    PIC S9(9) COMP.
 01 OUT-DATA.
     02 ARG-OUTDATA  PIC X(8).
 01 OUT-LEN.
     02 ARG-OUTLEN   PIC S9(9) COMP.
 COPY  EERPCSRV.
*
******************************************************************
*   プログラム開始
******************************************************************
 PROCEDURE       DIVISION
     USING IN-DATA IN-LEN OUT-DATA OUT-LEN EERPC_INTERFACE_TBL.
*
************************************************
*   トランザクション起動メッセージの表示
************************************************
*** LOGPRINT引数設定
 MOVE PGMID     TO
     EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1.
 MOVE MSGID65   TO
     EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1.
 MOVE MSG65     TO
     EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2.
 MOVE MSGLEN65  TO
     EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2.
 CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
     EELOG-PRINT-ARG3.
*
************************************************
*   RPC送信
************************************************
*** RPC送信データの設定
 MOVE ARG-INDATA OF IN-DATA TO
     EERPC-CALL-INDATA OF EERPC-CALL-ARG2.
 MOVE ARG-INLEN OF IN-LEN TO
     EERPC-CALL-INDATALEN  OF EERPC-CALL-ARG2.
 MOVE RPC-FLAGS      TO EERPC-CALL-FLAGS      OF EERPC-CALL-ARG1.
 MOVE RPC-SVNAME     TO EERPC-CALL-SVNAME     OF EERPC-CALL-ARG1.
 MOVE RPC-SVGROUP    TO EERPC-CALL-SVGROUP    OF EERPC-CALL-ARG1.
 MOVE RPC-OUTDATALEN TO EERPC-CALL-OUTDATALEN OF EERPC-CALL-ARG3.
*** RPC発行
 CALL 'CBLEERPC'
     USING EERPC-CALL-ARG1 EERPC-CALL-ARG2 EERPC-CALL-ARG3.
*** RPC成否判定
   IF EERPC-CALL-STATUS-CODE OF EERPC-CALL-ARG1
       NOT = EE_OK THEN
************************************************
*   RPC送信失敗
************************************************
*** RPC処理失敗メッセージの表示
*** LOGPRINT引数設定
   MOVE PGMID     TO
       EELOG-PRINT-PGM-ID  OF EELOG-PRINT-ARG1
   MOVE MSGID55   TO
       EELOG-PRINT-MSG-ID  OF EELOG-PRINT-ARG1
   MOVE MSG55     TO
       EELOG-PRINT-MSG     OF EELOG-PRINT-ARG2
   MOVE MSGLEN55  TO
       EELOG-PRINT-MSG-LEN OF EELOG-PRINT-ARG2
   CALL 'CBLEELOG' USING EELOG-PRINT-ARG1 EELOG-PRINT-ARG2
       EELOG-PRINT-ARG3
   END-IF.
*
******************************************************************
*   プログラム終了
******************************************************************
 EXIT PROGRAM.
 END PROGRAM SAMPLE_DBQ.
*