# Basic Functions
our $config_serverRoot = $ENV{'DOCUMENT_ROOT'};
our $config_postsDatabaseFolder = "$config_DatabaseFolder/posts";
our $config_commentsDatabaseFolder = "$config_DatabaseFolder/comments";	
our $config_dbFilesExtension = 'ppl';
our @keys = keys%config_commentsSecurityQuestion;

#HTML wird kodiert
sub r
{
	escapeHTML(param($_[0]));
}
#keine Kodierung
sub basic_r
{
	param($_[0]);
}

sub apo_r
{
	$_ = $_[0];
	s/'/&apos;/gi;
	return $_;
}

sub bbcode
#`Bbcode zu HTML
{
	$_ = $_[0];
	
#fix spaces in gallery bbcode	
s/\{gal\}\s?(.+?)\s?\{\/gal\}/\{gal\}$1\{\/gal\} /gi;

#get the path
my @array = split (/\s/, $_);
my @dirs = grep { /{gal}/&&/{\/gal}/; } @array;

s/'/&apos;/gi; # Jamesbond, solution to the ' giving problems in comments
s/¬/&#172;/gi;
s/\n/<br \/>/gi;
s/\{b\}(.+?)\{\/b\}/<b>$1<\/b>/gi;  
s/\{i\}(.+?)\{\/i\}/<i>$1<\/i>/gi;
s/\{u\}(.+?)\{\/u\}/<u>$1<\/u>/gi;
s/\{\*\}(.+?)\{\/\*\}/<li>$1<\/li>/gi;
s/\{style=(.+?)\}(.+?)\{\/style\}/<p style=$1>$2<\/p>/gi; 
s/\{qcode\}(.+?)\{\/qcode\}/<pre><code>$1<\/code><\/pre>/gi;  
s/\{img\}(.+?)\{\/img\}/<img src=$1 \/>/gi;
s/\{url\}(.+?)\{\/url\}/<a href=$1>$1<\/a>/gi; 
s/\{url=(.+?)\}(.+?)\{\/url\}/<a href=$1>$2<\/a>/gi;
s/\{box=(.+?) title=(.+?)\}(.+?)\{\/box\}/<input type=image class=thumb alt=$2 src=$1 title=$2 \/><div class=box><h3>$2<\/h3>$3<\/div>/gi; #bbcode for css lightboxes
s/\{(.+?)\/\}/<img src=$config_smiliesFolder\/$1.png \/>/gi; 	
	
#get pictures from folder and print lightboxes
foreach my $dir(@dirs){
	my $pictures;
	$dir =~ s/{gal}\W?(.+?)\W?{\/gal}/$1/;
	opendir (PIC,"$config_serverRoot/$dir");
	my @pics = grep {/(jpg|jpeg|png|gif)$/i;} readdir(PIC);
	
	foreach my $pic(@pics)
	{
			my $name=$pic;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
			
			if (-e "$config_serverRoot/$dir/thumbs"){
				$pictures .= "<input type=image class=thumb alt=$name src=$dir/thumbs/$pic title=$name /><div class=box><h3>$name</h3><img src=$dir/$pic /></div>";
			}
			else {
				$pictures .= "<input type=image class=thumb alt=$name src=$dir/$pic title=$name /><div class=box><h3>$name</h3><img src=$dir/$pic /></div>";
			}
		
	}
	s/\{gal}\W?$dir\W?\{\/gal}/$pictures/;
}  

	return $_;
}

sub bbdecode
#`HTML zu Bbcode
{
	$_ = $_[0];
s/\n//;
s/\<pre\>\<code\>(.+?)\<\/code\>\<\/pre\>/\{qcode\}$1\{\/qcode\}/gi;  
s/<br \/>//gi;
s/\<b\>(.+?)\<\/b\>/\{b\}$1\{\/b\}/gi;
s/\<i\>(.+?)\<\/i\>/\{i\}$1\{\/i\}/gi;
s/\<u\>(.+?)\<\/u\>/\{u\}$1\{\/u\}/gi;
s/\<li\>(.+?)\<\/li\>/\{\*\}$1\{\/\*\}/gi;
s/\<p style=(.+?)\>(.+?)\<\/p\>/\{style=$1\}$2\{\/style\}/gi; 
s/\<img src=$config_smiliesFolder\/(.+?).png \/\>/\{$1\/\}/gi; 
s/\<img src=(.+?)\/>/\{img\}$1\{\/img\}/gi;
s/\<a href=(.+?) \>(.+?)\<\/a\>/\{url=$1\}$2\{\/url\}/gi;
s/<input (.+?) src=(.+?)\/><div class=box><h3>(.+?)<\/h3>(.+?)<\/div>/\{box=$2\}$4\{\/box\}/gi; # lightboxes
	return $_;
}

sub bbcodeButtons #Efia buttons for entry and edit 
{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
	print qq\<fieldset class="screen">
			<input type="button" style="font-weight:bold" onClick="surroundText('{b}', '{/b}', document.forms.submitform.content); return false;" value="b" />
			<input type="button" style="font-style:italic" onClick="surroundText('{i}', '{/i}', document.forms.submitform.content); return false;" value="i" />
			<input type="button" style="text-decoration:underline" onClick="surroundText('{u}', '{/u}', document.forms.submitform.content); return false;" value="u" />
			<input type="button" style="color:red" onClick="surroundText('{style=text-align:;color:}', '{/style}', document.forms.submitform.content); return false;" value="style" title="$locale{$lang}->{style}" />
			<input type="button" onClick="surroundText('{*}', '{/*}', document.forms.submitform.content); return false;" value=" &#8226 li" title="$locale{$lang}->{list}" />
			<input type="button" onClick="surroundText('{qcode}', '{/qcode}', document.forms.submitform.content); return false;" value="&#34/.&#34" title="$locale{$lang}->{quote}" />
			<input type="button" onClick="surroundText('{url}', '{/url}', document.forms.submitform.content); return false;" value="http://" title="$locale{$lang}->{http}" />
            <input type="button" onClick="surroundText('{img}', '{/img}', document.forms.submitform.content); return false;" value="img" title="$locale{$lang}->{img}" />
			<input type="button" onClick="surroundText('{box= title=}','{/box}', document.forms.submitform.content); return false;" value="Box" title="$locale{$lang}->{box}" />
            <input type="button" onClick="surroundText('{gal}','{/gal}', document.forms.submitform.content); return false;" value="$locale{$lang}->{newGallery}"  title="$locale{$lang}->{gal}" />
			<div class="smilies">\;
		my @smilies = readdir (SM);
		closedir SM;
		foreach (@smilies){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'{'.$name.'/}\', \'\', document.forms.submitform.content); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
			
		
			#<input  type="button" onClick="surroundText(\'{\', \'/}\', document.forms.submitform.content); return false;" value=":-)"/>
			print '</div></fieldset><input class="screen" type=image alt="'.$locale{$lang}->{bbcode}.'"><div class=box /><iframe src=?BbcodeHelp=help#content target="_blank" width=650px height=90%></iframe></div>';

}

sub bbcodeComments #Buttons for comments
{
	opendir (SM, $config_serverRoot.$config_smiliesFolder);
		print qq\<fieldset class="screen">
			<input  type="button" style="font-weight:bold" onClick="surroundText('{b}', '{/b}', document.forms.submitform.comContent); return false;" value="b" />
			<input  type="button" style="font-style:italic" onClick="surroundText('{i}', '{/i}', document.forms.submitform.comContent); return false;" value="i" />
			<input  type="button" style="text-decoration:underline" onClick="surroundText('{u}', '{/u}', document.forms.submitform.comContent); return false;" value="u" />
			<input  type="button" style="color:red" onClick="surroundText('{style=text-align:;color:}', '{/style}', document.forms.submitform.comContent); return false;" value="style" title="$locale{$lang}->{style}"/>
			<input  type="button" onClick="surroundText('{*}', '{/*}', document.forms.submitform.comContent); return false;" value=" &#8226 li" title="$locale{$lang}->{list}" />
			<input  type="button" onClick="surroundText('{qcode}', '{/qcode}', document.forms.submitform.comContent); return false;" value="&#34/.&#34" title="$locale{$lang}->{quote}" />
			<input  type="button" onClick="surroundText('{url}', '{/url}', document.forms.submitform.comContent); return false;" value="http://" title="$locale{$lang}->{http}" />
            <input  type="button" onClick="surroundText('{img}', '{/img}', document.forms.submitform.comContent); return false;" value="img" title="$locale{$lang}->{img}" />
            <div class="smilies">\;
        while ($_ = readdir (SM)){
		foreach ($_){
			my $name = $_;
			$name =~s/(.+?).(jpg|jpeg|png|gif)/$1/gi;
				print '<input type="image" onClick="surroundText(\'{'.$name.'/}\', \'\', document.forms.submitform.comContent); return false;" src="'.$config_smiliesFolder.'/'.$_.'" title="'.$name.'" />' if $_ =~ /(jpg|jpeg|png|gif)$/i;
			}
		}	
		closedir SM;
			#<input  type="button" onClick="surroundText(\'{\', \'/}\', document.forms.submitform.content); return false;" value=":-)"/>
			print '</div></fieldset>';
}

sub getdate #Datum der Zeitzone anpassen
{
	my $gmt = $_[0];
	my $day = 1440;
	my $hour =  60;
	$gmt = $gmt*60;
	my $date = gmtime;
	my @dat = split(' ', $date);
	my @time = split(':',$dat[3]);
	
	my $minutes=$time[1]+($time[0]*60)+($dat[2]*1440);#Alles in Minutes
	my $value=$minutes+$gmt;
	my @time = ();

	my $d = int($value/$day); push (@time, $d); $value = ($value%$day);#Tag
	my $h = int($value/$hour); push (@time, $h); $value = ($value%$hour);#Stunde
	unless ($value =~ /\d\d/){$value = '0'.$value;}#Minuten zweistellig
	push (@time, $value);
	
	return $time[0].' '.$dat[1].' '.$dat[4].', '.$time[1].':'.$time[2];
}
#Jedes Objekt einmal wiedergeben
sub array_unique
{
	my %seen = ();
	@_ = grep { ! $seen{ $_ }++ } @_;
}

sub getFiles			# This function returns all files from the db folder
{
	my $dir=$_[0];
	if(!(opendir(DH, $dir)))
	{
		mkdir($dir, 0755);
	}
	
	my @entriesFiles = (); 		# This one has all files names
	my @entries = (); 			# This one has the content of all files not splitted
	
	foreach(readdir DH)
	{
		unless($_ eq '.' or $_ eq '..' or (!($_ =~ /$config_dbFilesExtension$/)))
		{
			push(@entriesFiles, $_);
		}
	}
	
	@entriesFiles = sort{$b <=> $a}(@entriesFiles);		# Here I order the array in descending order so i show Newest First
	
	foreach(@entriesFiles)
	{
		my $tempContent = '';
		open(FILE, "<".$dir."/$_");
		while(<FILE>)
		{
			$tempContent.=$_;
		}
		close FILE;
		push(@entries, $tempContent);
	}
	return @entries;
}

sub getCategories		# This function is to get the categories 
{						
	my @categories = ('General');
	my @tempCategories = ();
	if(-d "$config_postsDatabaseFolder")
	{
		my @entries = getFiles($config_postsDatabaseFolder);
		foreach(@entries)
		{
			my @finalEntries = split(/¬/, $_);
			my @split = split(/'/, $finalEntries[3]);#Falls mehr als eine Kategorie vorhanden ist
			push(@tempCategories, @split);
		}
		@categories = array_unique(@tempCategories);
	}
	return @categories;		
}
#Seiten finden
sub getPages
{
	open (FILE, "<$config_postsDatabaseFolder/pages.$config_dbFilesExtension.page");
	my $pagesContent;
	while(<FILE>)
	{
		$pagesContent.=$_;
	}
	close FILE;
	
	my @pages = split(/-/, $pagesContent);
}
#Kommentare finden
sub getComments
{
	open(FILE, "<$config_commentsDatabaseFolder/latest.$config_dbFilesExtension");
	my $content;
	while(<FILE>)
	{
		$content.=$_;
	}
	close(FILE);
	
	my @comments = split(/'/, $content);	
	@comments = reverse(@comments);			# We want newer first right?
}

#subs for the menu
sub menuMobileSearch
{
	print '<form id="mobile" accept-charset="UTF-8" name="form1" method="post">
	<input type="text" name="keyword">
	<input type="hidden" name="do" value="search">
	<input type="submit" name="Submit" value="'.$locale{$lang}->{search}.'">
	<input name="by" type="hidden" value="1">
	</form> ';
}
sub menuSearch
{
	print '<h1>'.$locale{$lang}->{search}.'</h1>
			<form accept-charset="UTF-8" name="form1" method="post">
			<input type="text" name="keyword" style="width:150px">', # search field 100613 added sc0ttmans UTF-8 fix
			'<input type="hidden" name="do" value="search"><br />
			'.$locale{$lang}->{bytitle}.'<input name="by" type="radio" value="0" checked> '.$locale{$lang}->{bycontent}.'<input name="by" type="radio" value="1">
			</form>';
}
sub menuEntries
{
	print'<h1>'.$locale{$lang}->{entries}.'</h1>';
	#latest entries 
	my @tmpEntries = getFiles($config_postsDatabaseFolder);
	my @entriesOnMenu=();
	my @pages = getPages();
	my $i = 0;

	foreach my $item(@tmpEntries)
		{
			my @split = split(/¬/, $item);
			unless (grep {$_ eq $split[4] } @pages){push(@entriesOnMenu, $item);}
		}

	foreach(@entriesOnMenu)
	{
		if($i <= $config_menuEntriesLimit)
		{
			my @entry = split(/¬/, $_);
			print '<a href="?viewDetailed='.$entry[4].'">'.$entry[0].'</a>';
			$i++;
		}
	}
}
sub menuCategories
{
	print' <h1>'.$locale{$lang}->{categories}.'</h1>';				
	my @categories = sort(getCategories());
	foreach(@categories)
	{
		print '<a href="?viewCat='.$_.'">'.$_.'</a>';
	}
}
sub menuComments
{
		
	my @comments = getComments();
	
	if(scalar(@comments) > 0)
	{
		print '<h1>'.$locale{$lang}->{comments}.'</h1>
		<a href="?do=listComments">'.$locale{$lang}->{listComments}.' »</a>';
	}
	
	my $i = 0;
	
	foreach(@comments)
	{
		if($i <= $config_showLatestCommentsLimit)
		{
			my @entry = split(/"/, $_);
			print '<a href="?viewDetailed='.$entry[4].'#'.$entry[5].'" title="'.$locale{$lang}->{entryby}.' '.$entry[1].'">'.$entry[0].'</a>'; #sc0ttman
			$i++;
		}
	}
}

#sub for contents
sub doPages
{	
	my @tempEntries = @_;
	my $do = shift @tempEntries;
	my $part = shift @tempEntries;
	
	# Pagination - This is the so called Pagination
	my $page = r('page');																# The current page
	if($page eq ''){ $page = 1; }													# Makes page 1 the default page
	my $totalPages = ceil((scalar(@tempEntries))/$config_entriesPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_entriesPerPage*$page);									# The array will start from this number
	my $arrayStart = $arrayEnd-($config_entriesPerPage-1);							# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;
	
    my $i = $arrayStart;															# Start Looping...
	while($i<=$arrayEnd)
	{
		unless($tempEntries[$i] eq '')
		{
			my @finalEntries = split(/¬/, $tempEntries[$i]);
			my @categories = split (/'/, $finalEntries[3]);
			
			my $commentsLink;
			my $tmpContent;
			open(FILE, "<$config_commentsDatabaseFolder/$finalEntries[4].$config_dbFilesExtension");
			while(<FILE>){$tmpContent.=$_;}
			close FILE;
					
			my @comments = split(/'/, $tmpContent);
			if(scalar(@comments) == 0)
				{
					$commentsLink = $locale{$lang}->{nocomment};
				}
			elsif(scalar(@comments) == 1)
				{
					$commentsLink = '1 '.$locale{$lang}->{comment};
				}
			else
				{
					$commentsLink = scalar(@comments).' '.$locale{$lang}->{comments};
				}
					
			if ($part == 1){
				# display the entries for admin pages
				print '<div class="article"><h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a> &nbsp; <small><a href="?edit=posts/'.$finalEntries[4].'">'.$locale{$lang}->{e}.'</a> - <a href="?delete=posts/'.$finalEntries[4].'">'.$locale{$lang}->{d}.'</a></small></h1>
				<a href="?viewDetailed='.$finalEntries[4].'">'.$commentsLink.'</a><br /><br />'.$finalEntries[1].'<br /></br><footer>'.$locale{$lang}->{postedon}.$finalEntries[2].' - '.$locale{$lang}->{categories}.':';
			}
			else{
				#show entries for main blog
				print '<div class="article"><h1><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[0].'</a></h1><a href="?viewDetailed='.$finalEntries[4].'">'.$commentsLink.' </a> '.$config_customHTMLpost.'</br>
				'.$finalEntries[1].'<br /><br /><footer id="footer">'.$locale{$lang}->{postedon}.' '.$finalEntries[2].' - '.$locale{$lang}->{categories}.': ';
			}
			for (0..$#categories)
				{
					print ' <a href="?viewCat='.$categories[$_].'">'.$categories[$_].'</a> ';   
				}
					print '<br /></footer><br /><br /></div>'; 
		}
		$i++;
	}
	#Pages
	if ($totalPages >= 1)
	{
		print $locale{$lang}->{pages};
	}
	else
	{
		print '<br />'.$locale{$lang}->{nopages1}.' <a href="?do=newEntry">'.$locale{$lang}->{nopages2}.'</a>?' if $part==1;
	}
	my $startPage = $page == 1 ? 1 : ($page-1);
	my $displayed = 0;
	for(my $i = $startPage; $i <= (($page-1)+$config_maxPagesDisplayed); $i++)
	{
		if($i <= $totalPages)
		{
			if($page != $i)
			{
				if($i == (($page-1)+$config_maxPagesDisplayed) && (($page-1)+$config_maxPagesDisplayed) < $totalPages)
				{
					print '<a href="'.$do.'page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="'.$do.'page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="'.$do.'page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}

}
sub doNewEntry
{
	# Blog Add New Entry Form
	# 100613 added sc0ttmans UTF-8 fix
		my @categories = getCategories();
		print '<form accept-charset="UTF-8" action="" name="submitform" method="post">
		<legend>'.$locale{$lang}->{new}.'...</legend>
		<p><label for ="title">'.$locale{$lang}->{title}.'</label>
		<input name=title type=text id=title></p>';
		
		bbcodeButtons();
		
		print '<label for"isHTML">'.$locale{$lang}->{ishtml}.' <span text="'.$locale{$lang}->{spanhtml}.'">(?)</span></label>
		<input type="checkbox" name="isHTML" value="1">
		<textarea name="content" id="content"></textarea> 
		<p><label for="category">'.$locale{$lang}->{categories}.' <span text="'.$locale{$lang}->{spancat}.'">(?)</span></label>
		<input name="category" type="text" id="category">';

			if( scalar(@categories) > 0){
			print "<select onChange=\"surroundText(value,'', document.forms.submitform.category );\" ><option selected='selected' disabled='disabled'>...</option>";
		
			foreach(@categories)	# Here we display a comma between categories so is easier to undesrtand
			{
				print '<option  value="'.$_.'\'" >'.$_.'</option>';
			}
		
			print '</select>';
		}
		print '</p>
		<p><label for="isPage">'.$locale{$lang}->{ispage}.' <span text="'.$locale{$lang}->{spanpage}.'">(?)</span></label>
		<input type="checkbox" name="isPage" value="1"></p>
		<p><input name="process" type="hidden" id="process" value="doEntry">
		<input type="submit" name="Submit" value="'.$locale{$lang}->{subentry}.'">';
		print '<input type="submit" name="Submit" value="'.$locale{$lang}->{newnote}.'">' if grep {$_ eq 'notes'} @config_pluginsAdmin;
		print '</p></form>';
}
#Kommentare auflisten
sub listComments
{
	print '<h1>'.$locale{$lang}->{comments}.'</h1>';
	my @comments = getComments();
	# This is pagination... Again :]
	my $page = r('page');												# The current page
	if($page eq ''){ $page = 1; }										# Makes page 1 the default page (Could be... $page = 1 if $page eq '')
	my $totalPages = ceil((scalar(@comments))/$config_commentsPerPage);	# How many pages will be?
	# What part of the array should i show in the page?
	my $arrayEnd = ($config_commentsPerPage*$page);						# The array will start from this number
	my $arrayStart = $arrayEnd-($config_commentsPerPage-1);				# And loop till this number
	# As arrays start from 0, i will lower 1 to these values
	$arrayEnd--;
	$arrayStart--;
	my $i = $arrayStart;												# Start Looping...
	if(scalar(@comments) > 0)
	{
		print '<table width="100%"><tr><td><b>'.$locale{$lang}->{comment}.'</b></td><td><b>'.$locale{$lang}->{entryby}.'</b></td><td><b>'.$locale{$lang}->{postunder}.'</b></td></tr>';
	}
	else
	{
		print $locale{$lang}->{nocomments};
	}
	while($i<=$arrayEnd)
	{
		unless($comments[$i] eq '')
		{
			my @finalEntries = split(/"/, $comments[$i]);

			print '<tr><td><a href="?viewDetailed='.$finalEntries[4].'#'.$finalEntries[5].'" title="'.$finalEntries[2].'">'.$finalEntries[0].'</a></td><td>'.$finalEntries[1].'</td><td><a href="?viewDetailed='.$finalEntries[4].'">'.$finalEntries[6].'</a></td></tr>';
		#Kommentar mit Anker und link zum post drucken
		}
		$i++;
	}
	# Now i will display the pages
	print '</table>'.$locale{$lang}->{pages} if scalar(@comments) > 0;
	my $startPage = $page == 1 ? 1 : ($page-1);
	my $displayed = 0;
	for(my $i = $startPage; $i <= (($page-1)+$config_maxPagesDisplayed); $i++)
	{
		if($i <= $totalPages)
		{
			if($page != $i)
			{
				if($i == (($page-1)+$config_maxPagesDisplayed) && (($page-1)+$config_maxPagesDisplayed) < $totalPages)
				{
					print '<a href="?do=listComments&page='.$i.'">['.$i.']</a> ...';
				}
				elsif($startPage > 1 && $displayed == 0)
				{
					print '... <a href="?do=listComments&page='.$i.'">['.$i.']</a> ';
					$displayed = 1;
				}
				else
				{
					print '<a href="?do=listComments&page='.$i.'">['.$i.']</a> ';
				}
			}
			else
			{
				print '['.$i.'] ';
			}
		}
	}
	print '';
}

sub doSearch
{
	# Search Function

	my $keyword = r('keyword');
	my $do = 1;
	
	if(length($keyword) < 4)
	{
		print $locale{$lang}->{keyword};
		$do = 0;
	}
	
	my $by = r('by');							# This can be 0 (by title) or 1 (by id) based on the splitted array
	if(($by != 0) && ($by != 1)){ $by = 0; }	# Just prevention from CURL or something...
	my $sBy = $by == 0 ? $locale{$lang}->{bytitle} : $locale{$lang}->{bycontent};	# This is a shorter way of "my $sBy = ''; if($by == 0) { $sBy = 'Title'; } else { $sBy = 'Content'; }"
	
	if($do == 1)
	{
		print '</br>'.$locale{$lang}->{searchfor}.'"'.$keyword.'" '.$sBy.':<br /><br />';
		my @entries = getFiles($config_postsDatabaseFolder);
		my $matches = 0;
		foreach(@entries)
		
		{
			my @currEntry = split(/¬/, $_);
			if(($currEntry[$by] =~ m/$keyword/i))
			{
				
				print '<a href="?viewDetailed='.$currEntry[4].'">'.$currEntry[0].'</a><br />';	
				$matches++;
					
			}
			
		}
		print '<br />'.$matches.$locale{$lang}->{matches};
	}
}

sub doArchive
{# Show blog archive
	
	print '<h1>'.$locale{$lang}->{archive}.'</h1>';
	my @entries = getFiles($config_postsDatabaseFolder);
	print $locale{$lang}->{noentries} if scalar(@entries) == 0;
	# Split the data in the post so i have them in this format "13 Dic 2008, 24:11|0001|Entry title" date|fileName|entryTitle
	my @dates = map { my @stuff = split(/¬/, $_); @stuff[2].'|'.@stuff[4].'|'.@stuff[0]; } @entries; #25.05.13 jamesbond
	my @years;
	foreach(@dates)
	{
		my @date = split(/\|/, $_);
		my @y = split(/\s/, $date[0]);
		$y[2] =~ s/,//;
		if($y[2] =~ /^\d+$/)
		{
			push(@years, $y[2]);
		}
	}
	@years = reverse(sort(array_unique(@years)));
	my $page = r('p');
	if ($page eq ''){$page = 1;}
	my $i = ($page - 1);
	my $totalPages = scalar@years; #Seite pro jahr
	
	if ($years[$i]){
		# Monate in die richtige Reihenfolge bringen
		print "<h1><small>$years[$i]</small></h1>";
		my @months = qw(Dic Nov Oct Sep Aug Jul Jun May Apr Mar Feb Jan);

		for my $actualMonth(@months){ 
			my @entries = grep{/$actualMonth\s$years[$i]/}@dates;
			next if scalar @entries ==0;
			@entries = sort {$a<=>$b}reverse(@entries);
			print '<div class="slide"><a id="flip" href="">'.$locale{$lang}->{$actualMonth}.' ('.scalar @entries.' '.$locale{$lang}->{entries}.') »</a><table class="hide">';
			#Enträge nah Datum wiedergeben
			foreach (@entries){
				my @e = split(/\|/,$_);
				my @d = split(/\s/,$e[0]);
				print '<tr><td style="text-align:right">'.$d[0].'</td><td><a href="?viewDetailed='.$e[1].'">'.$e[2].'</a></td></tr>';
				}
				print "</table></div><br />";
			}
		}

		print '<br />'.$locale{$lang}->{year}.': ';
		$i = 0;
		while ($years[$i]) {
			my $j = ($i+1);
			print '<a href="?do=archive&p='.$j.'">'.$years[$i].'</a> ';
			$i++;
		}			
}

sub BbcodeHelp 
# Help Page for Bbcode
{	print <<EOF;
<h1>Bbcode Hilfe</h1>
Text:</br>
<b>{b}fett{/b}</b> <i>{i}kursiv{/i}</i>  <u>{u}unterstrichen{/u}</u></br>
<p style=text-align:center;color:blue;font-size:20px>{style=text-align:center;color:blue;font-size:30px}Text Formattierungsmöglichkeiten {/style}</p>
<li>{*}eine{/*}</li><li>{*}Liste{/*}</li><li>{*}erstellen{/*}<br />
<br />
<code><pre>{qcode}Jemanden Zitieren oder Code zeigen{/qcode}</pre></code><br />
<br />
Smileys:<br />
{Beispiel/} ertellt einen Smiley. In dem "/images/smilies" Ordner können Smileys hinzugefügt oder verändert werden. Der Dateiname (example.png) wird benutzt um sie aufzurufen.</br>
<br />
Medien:<br />
{img}hier einen Link oder Pfad zum Bild eintragen (+Optionen){/img}<br />
{url=http://webseite.com (options)}link{/url} <a href=#>link</a><br />
{box=Thumbnail title=Titel}Bild{/box} eine Lightbox, um ein Bild einzufügen oder ähnliches einzufügen Bbcode benutzen. Eine Textbox mit dem style button erstellen.
Falls kein Thumbnail vorhanden ist, ist der Titel ein Link..<br /><br />
Den "Gallerie" Button benutzen um eine Gallerie von Bildern in einem Ordner zu erstellen; 
Pfad zu dem Ordner von dem Hauptverzeichnis des Servers aus angeben, Thumbnails werden entweder aus 
dem Ordner "thumbs" (gleiche Namen wie die Originalbilder) genommen oder die Originalbilder 
werden auf Thumbnailgröße geschrumpft (bei großen Bilder wird das die Ladezeit beeinflussen)<br />
<br />
Mehr Möglichkeiten: <br />
Weitere (+Optionen) können an der angegebenen Stelle eingetragen werden;<br /> Zum Beispiel: {img}bild.jpg title=Bildtext{/img}<br />
Der Einfachkeit halber sind schon einige Optionen dem "Style" Button hinzugefügt worden, falls es nicht gebraucht wird, leer lassen</br>
<br />
Beispiele für Optionen:<br />
alt= Titel<br />
title= Bildbeschriftung<br />
width= Weite<br />
height= Höhe</br>
EOF
}
# Javascript für Bbcode	Schaltflächen
sub javascript 
{
	print <<EOF;
	<script language="javascript" type="text/javascript">
// FUNCTION BY SMF FORUMS http://www.simplemachines.org
function surroundText(text1, text2, textarea)
{
	// Can a text range be created?
	if (typeof(textarea.caretPos) != "undefined" && textarea.createTextRange)
	{
		var caretPos = textarea.caretPos, temp_length = caretPos.text.length;

		caretPos.text = caretPos.text.charAt(caretPos.text.length - 1) == \' \' ? text1 + caretPos.text + text2 + \' \' : text1 + caretPos.text + text2;

		if (temp_length == 0)
		{
			caretPos.moveStart("character", -text2.length);
			caretPos.moveEnd("character", -text2.length);
			caretPos.select();
		}
		else
			textarea.focus(caretPos);
	}
	// Mozilla text range wrap.
	else if (typeof(textarea.selectionStart) != "undefined")
	{
		var begin = textarea.value.substr(0, textarea.selectionStart);
		var selection = textarea.value.substr(textarea.selectionStart, textarea.selectionEnd - textarea.selectionStart);
		var end = textarea.value.substr(textarea.selectionEnd);
		var newCursorPos = textarea.selectionStart;
		var scrollPos = textarea.scrollTop;

		textarea.value = begin + text1 + selection + text2 + end;

		if (textarea.setSelectionRange)
		{
			if (selection.length == 0)
				textarea.setSelectionRange(newCursorPos + text1.length, newCursorPos + text1.length);
			else
				textarea.setSelectionRange(newCursorPos, newCursorPos + text1.length + selection.length + text2.length);
			textarea.focus();
		}
		textarea.scrollTop = scrollPos;
	}
	// Just put them on the end, then.
	else
	{
		textarea.value += text1 + text2;
		textarea.focus(textarea.value.length - 1);
	}
}
</script>
EOF
}

#JQuery functions
sub JQuery
{
	print q \
	<script src="https://code.jquery.com/jquery-1.9.1.min.js"></script> 
	 <script> $(document).ready(function(){$(".hide").hide();
     $(".slide #flip").click(function(event){
	 $(this).next(".hide").toggle("slow"); 
		event.preventDefault(); });
	$("#mobile").click(function(event){$("header div, form#mobile").slideToggle("slow");
		event.preventDefault(); });
	$("[name='isHTML']").click(function(){
		if($("[name='isHTML']").is(":checked"))
		{
			$(".screen").hide(); 
		}
		else
		{
			if ($(window).width()>=550){
				$(".screen").show(); 
			}
		}
		});
	});</script>\;
}	

#IP Adressen im Standartformat wiedergeben
sub getIP
{
	my $ip;
	if (defined $ENV{'HTTP_X_FORWARDED_FOR'}){
		$ip = $ENV{'HTTP_X_FORWARDED_FOR'}; 
		$ip =~ s/::ffff:(.*)/$1/;
		}
	else {$ip = $ENV{'REMOTE_ADDR'};}
	return $ip;
}


return 1;