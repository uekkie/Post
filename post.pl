use strict;
use warnings;

#==============================
# 備忘録エリア
#
#	%prevData = ();			ハッシュの初期化
#	defined $hs{"pcode"}	ハッシュの定義確認



# 住所1件をハッシュ配列化します
sub hashPost {
	my %items;
	@items{ qw/pcode pref city town prefjp cityjp townjp/  } = split( ',', shift );
	%items;
}

#
# 必要なデータに整形する
#	01101,"060  ","0600000","ﾎｯｶｲﾄﾞｳ","ｻｯﾎﾟﾛｼﾁｭｳｵｳｸ","ｲｶﾆｹｲｻｲｶﾞﾅｲﾊﾞｱｲ","北海道","札幌市中央区","以下に掲載がない場合",0,0,0,0,0,0
#			↓↓↓
#	"0600000","ﾎｯｶｲﾄﾞｳ","ｻｯﾎﾟﾛｼﾁｭｳｵｳｸ","ｲｶﾆｹｲｻｲｶﾞﾅｲﾊﾞｱｲ","北海道","札幌市中央区","以下に掲載がない場合",
#
sub trim_data {
	# リスト代入を使って、スカラー変数に代入
	my ( $file_in, $file_out ) = @_; 
	
	while (<$file_in>) {
		# コンマ区切りで配列に格納
		my @datas = split(',' , $_);
		my $result = "";

		for (@datas) {
			# ダブルコーテーションで囲まれたデータのみ残す
			# 旧郵便番号データは要らない(数字:3<=X<=5、半角SP:0<=X<=2 のデータ)
			$result .= "$_," if (/^\".+\"$/ && ! /\"[0-9]{3,5} {0,2}\"/);
		}
		print $file_out "$result\n";
	}
}

#
# 京都府の複数行に分割されたデータをまとめる
#
sub kyoto_merge {
	# リスト代入を使って、スカラー変数に代入
	my ( $file_in, $file_out ) = @_; 
	my %cur_addr	= ();
	my %prev_addr	= ();

	while (<$file_in>) {
		unless ( defined $prev_addr{"pcode"}) {
			%prev_addr = hashPost($_);
			next;
		}
		%cur_addr = hashPost($_);
		if ($cur_addr{"pcode"} eq $prev_addr{"pcode"} ) {
			# ”町域名”を連結
			$prev_addr{"townjp"}	=~ s/(^\"|\"$)//g;					# 二重引用符を除去
			$cur_addr{"townjp"}		=~ s/^\"/\"$prev_addr{"townjp"}/g;	# 正規表現で置換して連結
			%prev_addr = %cur_addr;
			
		} else {
			print $file_out join( ",", @prev_addr{qw/pcode pref city town prefjp cityjp townjp/} ).",\n";
			%prev_addr = %cur_addr;
		}
	}
	# 末尾のデータを出力する
	unless ( scalar( keys( %prev_addr )) == 0) {
		print $file_out join( ",", @prev_addr{qw/pcode pref city town prefjp cityjp townjp/} ).",\n";
	}
}


# 処理するファイルをコマンド引数で受け取る
sub main {
	my $fname_in = shift;
	# ファイル拡張子チェック
	if ($fname_in !~ /\.csv$/) {
		print "please select CSV file.\n";
		return;
	}
	my $fname_out = $fname_in;
	$fname_out =~ s/\./\.out\./g;
	
	open(my $fh_in, "<", $fname_in) or die("could not open file.");
	open(my $fh_out, ">", $fname_out) or die("could not open file.");
	
	
	#trim_data($fh_in, $fh_out);
	kyoto_merge($fh_in, $fh_out);
	
	close($fh_in);
	close($fh_out);
}

main($ARGV[0]);

#my %d = hashPost('"0600000","ﾎｯｶｲﾄﾞｳ","ｻｯﾎﾟﾛｼﾁｭｳｵｳｸ","ｲｶﾆｹｲｻｲｶﾞﾅｲﾊﾞｱｲ","北海道","札幌市中央区","以下に掲載がない場合"');
#print $d{"pcode"} eq '"0600000"' ? "aa" : "bb";