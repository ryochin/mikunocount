ミクノ度算出プログラム
------------------

手元でミクノ度 JSON ファイルを生成するスクリプトです。  
旧まとめサイトで運用していたプログラムを全面的に書き直しました。

概要
---

実行すると count.json ファイルを生成します。

必要なもの
--------

* perl

Windows なら [ActivePerl](http://www.activestate.com/activeperl/downloads) などが使えます。

また、次の Perl モジュールが必要です。

* YAML::Syck
* URI::Fetch

Unix 系 OS なら次のコマンドで導入できます。

	sudo cpan YAML::Syck URI::Fetch

ActivePerl で動かすには、cmd.exe から次のようにしてみてください。

	ppm install YAML::Syck
	ppm install URI::Fetch

使い方
-----

	perl create_count_json.pl

同じディレクトリに count.json が保存されます。

Windows (ActivePerl) ならスクリプトをダブルクリックで起動するだけです。

詳しい使い方
----------

	usage: create_count_json.pl [-vy] [-c <config yaml>] [-o <output json>]

* -v: デバッグ情報を出力する
* -c: 設定ファイル　（デフォルトは ./setting.yml）
* -o: 出力する JSON ファイル　（デフォルトは ./count.json）
* -y: YAML として保存する　（デバッグ用）

運用について
----------

設定ファイルは setting.yml です。適宜編集してください。

* 掲示板のスレッドが増えたら board に追加します。
* ジングルなどが増えたら ignore に追加します。
* 手動補正が必要なら correction に追加します。

ライセンス
--------

いちおう BSD ライセンスにしておきます。