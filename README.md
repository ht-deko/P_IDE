# P_IDE
Windows 用の Pascal-Px IDE です。

![image](https://user-images.githubusercontent.com/14885863/147760150-e8be5d2b-6dc8-4e96-a769-44aa2996f97e.png)

## Pascal-P4

**Pascal-P4** は Scott A. Moore 氏が改変した Pascal-P4 コンパイラです。

 - [PASCAL-P4 (SourceForge)](https://sourceforge.net/projects/pascalp4/)

P-CODE コンパイラ/インタプリタが `binaries\P4` フォルダに格納されています。

## Pascal-P5

**Pascal-P5** は Scott A. Moore 氏による ISO 標準 Pascal 水準 0 に準拠した Pascal です。

 - [PASCAL-P5 (SourceForge)](https://sourceforge.net/projects/pascalp5/)

P-CODE コンパイラ/インタプリタが `binaries\P5` フォルダに格納されています。

 - [PASCAL-P5 (Github)](https://github.com/ht-deko/Pascal-P5/tree/main)

Delphi でコンパイルできるバージョンもあります。

## Pascal-P6

**Pascal-P6** は Richard Sprague 氏による ISO 標準 Pascal 水準 1 に準拠した Pascal です。

 - [Pascal-P6 (wirth-dijkstra-langs.org)](http://wirth-dijkstra-langs.org/)

P-CODE コンパイラ/インタプリタが `binaries\P6` フォルダに格納されています。

## Pascal-S

**Pascal-S** は Scott A. Moore 氏が改変した Pascal-S コンパイラ/インタプリタです。いわゆるインタプリタなので P-CODE を出力しません。

 - [PASCAL-S (SourceForge)](https://sourceforge.net/projects/pascal-s/)

コンパイラ/インタプリタが `binaries\PS` フォルダに格納されています。Delphi でコンパイルできるソースコード `PascalS_mod.dpr` が `source` フォルダにあります。

## PL/0

**PL/0** は Pascal サブセットのコンパイラ/インタプリタです。

 - [PL/0 (pascal.hansotten.com)](http://pascal.hansotten.com/niklaus-wirth/pl0/)

コンパイラ/インタプリタが `binaries\PL0` フォルダに格納されています。Delphi でコンパイルできるソースコード `pl0_mod.dpr` が `source` フォルダにあります。

## Delphi CC

**Delphi CC** は Delphi のコマンドラインコンパイラです。

 - [DCC32.EXE - Delphi コマンドライン コンパイラ (DocWiki)](https://docwiki.embarcadero.com/RADStudio/ja/DCC32.EXE_-_Delphi_%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3_%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9)

`binaries\DP` フォルダには IDE のみ格納されています。実行には Delphi のインストールが必要です。

`$(BDS)\BIN\DCC32.CFG` に次の一行を加えると uses 句のユニットスコープ名を省略 (短縮) できます。

```
-NSWinapi;System.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Xml;Data;Datasnap;Web;Soap;
```


## 使い方

`P4.EXE` / `P5.EXE` / `P6.EXE` / `PS.EXE` / `PL0.EXE` / `DP.EXE` を実行してください。IDE は Turbo Pascal 3.x ライクな操作となっています。

![image](https://user-images.githubusercontent.com/14885863/150693254-14b80af5-eeb3-46ec-a81c-f465f678a2cf.png)

### ・Logged drive:
カレントドライブ。
`C:\WORK` のようにパスと同時に指定可能。

### ・Active directory:
カレントディレクトリ。
`C:\WORK` のようにドライブと同時に指定可能。

### ・Work file:
編集/コンパイル対象のファイル。
ファイル名だけを指定するとカレントディレクトリのファイルとみなす。拡張子を指定しなかった場合には `*.pas` であるとみなす (PL/0 の場合には `*.pl0`)。

### ・Main file: (DP.EXE のみ)
コンパイル対象のファイル。メインファイルが指定されている場合、ワークファイルが何であれメインファイルをコンパイルする。
ファイル名だけを指定するとカレントディレクトリのファイルとみなす。拡張子を指定しなかった場合には `*.pas` であるとみなす (PL/0 の場合には `*.pl0`)。

### ・Edit
外部エディタを起動する。デフォルトで **Micro Editor** (MICRO.EXE) を使う。

 - [Micro text editor](https://micro-editor.github.io/)

![image](https://user-images.githubusercontent.com/14885863/147763900-fce5eead-e0c5-48ed-9325-0539291c691b.png)

MICRO.EXE がインストールされていないか、パスに含まれていない場合、IDE は `COPY CON` でファイルを新規作成する。終了は〔Ctrl〕+〔Z〕。

### ・Compile
コンパイラ `PCOM.EXE` を呼び出す。Pascal-S / PL/0 の場合、`Compile` と `Run` は同じ動作になる。

![image](https://user-images.githubusercontent.com/14885863/147763836-2b085528-4d5b-477d-a872-b5a1224da2e6.png)

正しくコンパイルできるとソースファイルと同じフォルダに `*.px` ファイル (x はバージョン番号) を吐く。Pascal-S / PL/0 の場合には出力されない。

### ・Run
インタプリタ `PINT.EXE` を呼び出す。Pascal-S の場合 `PASCALS_mod.EXE` を呼び出す。PL/0 の場合、`PL0_mod.exe` を呼び出す。

![image](https://user-images.githubusercontent.com/14885863/147763815-bc186ea5-5a68-4100-bb29-8307c5ee4bd2.png)

`*.px` ファイル (x はバージョン番号) を解釈して実行する。Pascal-S / PL/0 の場合にはソースファイルを直接解釈して実行する。

### ・More
コンパイラ等の外部コマンドを呼び出し時の `MORE` コマンド使用を切り替える。 (トグル動作)

`MORE` の操作は次の通り。

| キー | 説明 |
|:---:|:---|
| 〔Enter〕| 次の行を表示します。 |
| 〔Space〕| 次ページを表示します。 |
| 〔Q〕| 終了します。 |

### ・Dir
`CMD.EXE` の `DIR` をカレントディレクトリ (Active Directory) で実行する。`Dir mask:` に何も入力しないと全ファイルをリストアップする。`Dir mask:` には `*.pas` のようにワイルドカードを指定可能。

### ・Get
`CURL.EXE` (Windows 10 以降は標準で付属) を呼び出す。

![image](https://user-images.githubusercontent.com/14885863/147763748-d2591288-ec36-4f2a-89e8-476fd4f29fa6.png)

ファイルはカレントディレクトリ (Active Directory) に保存される。

### ・Type
ファイルの内容を表示する。
外部エディタがインストールされていない場合のファイル内容確認はこれを用いる。

### ・Quit
Pascal IDE を終了する。

### ・Hide Menu
メニューを非表示にし、プロンプトだけを表示する。 (トグル動作)

## ソースコードのコンパイル

最近の Delphi でコンパイルできます。無償の Community Edition でも大丈夫です。

 - [Delphi Community Edition (Embarcadero)](https://www.embarcadero.com/jp/products/delphi/starter)

### CRT32

リポジトリに含まれている `CRT32.PAS` は、[Delphi Zone](http://www.delphi-zone.com/2010/09/how-to-use-a-crt-unit-for-delphi/) にあったものを [Warren Postma 氏が Unicode 版 Delphi 向けに改変したもの](https://onedrive.live.com/embed?cid=F5BB35AE00415BC7&resid=F5BB35AE00415BC7%21232&authkey=AIKZAtMjhUyE-TQ)を改変したユニットです。

### ライセンス

ライセンスは設定していません。コードスニペット扱いとしますので、自由に改変してお使いください。
