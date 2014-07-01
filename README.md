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

Windows なら [Strawberry Perl](http://strawberryperl.com/) を入れます。

また、次の Perl モジュールが必要です。

* YAML::Syck
* URI::Fetch

Strawberry Perl で動かすには、`cmd.exe` を起動して次のようにして必要なライブラリを入れます。

	\strawberry\perl\bin\cpan YAML::Syck URI::Fetch

Unix 系 OS なら次のコマンドで導入できます。

	sudo cpan YAML::Syck URI::Fetch

使い方
-----

コマンドラインからは次のように実行します。

	perl create_count_json.pl

同じディレクトリに `count.json` が保存されます。

crontab に仕込むとよいでしょう。

Windows (Strawberry Perl) ならスクリプトをダブルクリックで起動するだけです。  
正常に終了するとなにもメッセージは出ずにウィンドウが閉じます。

詳しいオプション
-------------

	usage: create_count_json.pl [-vy] [-c <config yaml>] [-o <output json>]

* -v: デバッグ情報を出力する
* -c: 設定ファイル　（デフォルトは ./setting.yml）
* -o: 出力する JSON ファイル　（デフォルトは ./count.json）
* -y: YAML として保存する　（デバッグ用）

運用について
----------

設定ファイルは `setting.yml` です。適宜編集してください。

* 掲示板のスレッドが増えたら board に追加します。
* ジングルなどが増えたら ignore に追加します。
* 手動補正が必要なら correction に追加します。

わかりにくいかもしれません、私まで質問ください。

カウントの仕様について
------------------

* まとめ wiki のドキュメントに基本的な方針が書いてあります。
* 総合スレでも何度か議論されています。「ミクノ度」などでページ内を検索してみてください。

個人的なお願い
------------

* できればきちんとプレイリストのずれを補正したものを本運用してください。

ライセンス
--------

いちおう BSD ライセンスにしておきます。