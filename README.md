# P_IDE
Windows 用の Pascal-Px IDE です。

![image](https://user-images.githubusercontent.com/14885863/147760150-e8be5d2b-6dc8-4e96-a769-44aa2996f97e.png)

## Pascal-P4

**Pascal-P5** は Scott A. Moore 氏による Pascal-P4 コンパイラです。

 - [PASCAL-P4 (SourceForge)](https://sourceforge.net/projects/pascalp4/)

P-CODE コンパイラ/インタプリタが `binaries\P4` フォルダに格納されています。

## Pascal-P5

**Pascal-P5** は Scott A. Moore 氏による ISO 標準 Pascal 水準 0 に準拠した Pascal です。

 - [PASCAL-P5 (SourceForge)](https://sourceforge.net/projects/pascalp5/)

P-CODE コンパイラ/インタプリタが `binaries\P5` フォルダに格納されています。

## Pascal-P6

**Pascal-P6** は Richard Sprague 氏による ISO 標準 Pascal 水準 1 に準拠した Pascal です。

 - [Pascal-P6 (wirth-dijkstra-langs.org)](http://wirth-dijkstra-langs.org/)

P-CODE コンパイラ/インタプリタが `binaries\P6` フォルダに格納されています。


## 使い方

`P5.EXE` か `P6.EXE` を実行してください。IDE は Turbo Pascal 3.x ライクな操作となっています。

![image](https://user-images.githubusercontent.com/14885863/147762644-60a2fffa-392f-483c-b9fc-ace7fc2ae6c9.png)

### ・Logged drive:
カレントドライブ。
`C:\WORK` のようにパスと同時に指定可能。

### ・Active directory:
カレントディレクトリ。
`C:\WORK` のようにドライブと同時に指定可能。

### ・Work file:
編集/コンパイル対象のファイル。
ファイル名だけを指定するとカレントディレクトリのファイルとみなす。拡張子を指定しなかった場合には `*.pas` であるとみなす。

### ・Edit
外部エディタを起動する。デフォルトで **Micro Editor** (MICRO.EXE) を使う。

 - [Micro text editor](https://micro-editor.github.io/)

![image](https://user-images.githubusercontent.com/14885863/147763900-fce5eead-e0c5-48ed-9325-0539291c691b.png)

MICRO.EXE がインストールされていないか、パスに含まれていない場合、IDE は `COPY CON` でファイルを新規作成する。終了は〔Ctrl〕+〔Z〕。

### ・Compile
コンパイラ `PCOM.EXE` を呼び出す。

![image](https://user-images.githubusercontent.com/14885863/147763836-2b085528-4d5b-477d-a872-b5a1224da2e6.png)

正しくコンパイルできるとソースファイルと同じフォルダに `*.p5` (または `*.p6`) ファイルを吐く。

### ・Run
インタプリタ `PINT.EXE` を呼び出す。

![image](https://user-images.githubusercontent.com/14885863/147763815-bc186ea5-5a68-4100-bb29-8307c5ee4bd2.png)

`*.p5`  (または `*.p6`) ファイルを解釈して実行する。

### ・Dir:
`CMD.EXE` の `DIR | MORE` をカレントディレクトリ (Active Directory) で実行する。
`MORE` の操作は次の通り。

| キー | 説明 |
|:---:|:---|
| 〔Enter〕| 次の行を表示します。 |
| 〔Space〕| 次ページを表示します。 |
| 〔Q〕| 終了します。 |

### ・Get
`CURL.EXE` (Windows 10 以降は標準で付属) を呼び出す。

![image](https://user-images.githubusercontent.com/14885863/147763748-d2591288-ec36-4f2a-89e8-476fd4f29fa6.png)

ファイルはカレントディレクトリ (Active Directory) に保存される。

### ・Type
ファイルの内容を表示する。
外部エディタがインストールされていない場合のファイル内容確認はこれを用いる。

### ・Quit:
Pascal IDE を終了する。

## ソースコードのコンパイル

最近の Delphi でコンパイルできます。無償の Community Edition でも大丈夫です。

 - [Delphi Community Edition (Embarcadero)](https://www.embarcadero.com/jp/products/delphi/starter)

### CRT32

リポジトリに含まれている `CRT32.PAS` は、[Delphi Zone](http://www.delphi-zone.com/2010/09/how-to-use-a-crt-unit-for-delphi/) にあったものを [Warren Postma 氏が Unicode 版 Delphi 向けに改変したもの](https://onedrive.live.com/embed?cid=F5BB35AE00415BC7&resid=F5BB35AE00415BC7%21232&authkey=AIKZAtMjhUyE-TQ)を改変したユニットです。

### ライセンス

ライセンスは設定していません。コードスニペット扱いとしますので、自由に改変してお使いください。
