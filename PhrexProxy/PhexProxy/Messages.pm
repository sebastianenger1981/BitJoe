#!/usr/bin/perl -I/server/phexproxy/PhexProxy

#########################################
##### Author:		Sebastian | modified 27.07.06 Torsten
##### CopyRight:	BitJoe GmbH
##### LastModified	27.07.06
##### Function:		Dateitypen definieren
##### Todo:			
########################################

package PhexProxy::Messages;

use PhexProxy::Time;
use strict;

my $VERSION = '0.18';
my $TIME	= PhexProxy::Time->new();



sub new(){
	
	my $self = bless {}, shift;
	$self->{'MessageHandler'}	= $self->Messages();
	$self->{'MessageHandlerEN'}	= $self->MessagesEN();
	return $self;
		
}; # new()
  


sub WelcomeMessageHandler(){

	my $self							= shift;
	my $ResultHashRef					= shift;
	my $language						= shift;

	my $hc_contingent_volume_success	= $ResultHashRef->{'searchcontingent'};
	my $MessageHandlerString			= "";

	if ( $language eq "GER") {
		$MessageHandlerString = "MessageHandler";
	} elsif ( $language eq "EN" ) {
		$MessageHandlerString = "MessageHandlerEN";
	}
	
	if ( $hc_contingent_volume_success > 4 ) {
		return $self->{$MessageHandlerString}{'G5'};
	} elsif ( $hc_contingent_volume_success == 4 ) {
		return $self->{$MessageHandlerString}{'G4'};
	} elsif ( $hc_contingent_volume_success == 3 ) {
		return $self->{$MessageHandlerString}{'G3'};
	} elsif ( $hc_contingent_volume_success == 2 ) {
		return $self->{$MessageHandlerString}{'G2'};
	} elsif ( $hc_contingent_volume_success == 1 ) {
		return $self->{$MessageHandlerString}{'G1'};
	} elsif ( $hc_contingent_volume_success <= 0 ) {
		return $self->{$MessageHandlerString}{'G0'};
	}; # if ( $hc_contingent_volume_success > 4 ) {

	#	if ( $hc_contingent_volume_success >= 3 || !defined($hc_contingent_volume_success) ) {
	#		return $self->{$MessageHandlerString}{'E5'};
	#	} elsif ( $hc_contingent_volume_success == 2 ) {
	#		return $self->{$MessageHandlerString}{'E4'};
	#	} elsif ( $hc_contingent_volume_success == 1 ) {
	#		return $self->{$MessageHandlerString}{'E3'};
	#	} elsif ( $hc_contingent_volume_success <= 0 ) {
	#		return $self->{$MessageHandlerString}{'E0'};
	#	}; # if ( $hc_contingent_volume_success >= 3 ) {

	# never reached 
	return $self->{$MessageHandlerString}{'1'};

}; # sub WelcomeMessageHandler(){



sub Messages(){
	
	my $self = shift;
	my $MessageHandler;
	
	$MessageHandler->{ '1' } = "Hinweis: Dein Konto kannst Du unter www.bitjoe.de/login aufladen!";			# Hallo Messages
	$MessageHandler->{ '2' } = "Deine bitjoe.de Version ist gueltig!";														# licence valid status message
	# $MessageHandler->{ '3' } = "Deine bitjoe.de Zugangsdaten sind falsch! Unter www.bitjoe.de kannst du dich anmelden und kostenlos testen. Unter www.bitjoe.de/login kannst du deine Daten einsehen.";	# licence invalid status=-1 message
	$MessageHandler->{ '3' } = "Deine bitjoe.de Zugangsdaten sind falsch! Unter www.bitjoe.de kannst Du die neuste BitJoe Software downloaden und kostenlos testen. Unter www.bitjoe.de/login kannst Du deine Daten einsehen.";	# licence invalid status=-1 message
	$MessageHandler->{ '31' } = "Dein bitjoe.de Volumen Tarif ist aufgebraucht. Unter bitjoe.de/login kannst du dein Guthaben aufladen um weiter zu suchen. Wir empfehlen Dir die bitjoe.de Flatrate!";	# licence invalid status=0 message
	$MessageHandler->{ '4' } = "FehlerCode 1001. Der Vorgang wurde abgebrochen.";											# crypto key error
	$MessageHandler->{ '5' } = "Der bitjoe.de Service ist aktuell ausgelastet, bitte versuche es in 2 Minuten wieder.";		# load to high error message
	$MessageHandler->{ '6' } = "Es trat ein Server Fehler beim Installieren deines Codes auf.";		
	$MessageHandler->{ '7' } = "Leider keine Treffer";		
	$MessageHandler->{ '8' } = "Es trat ein Server Fehler beim Ausführen Deines Bezahlvorganges auf.";		
	$MessageHandler->{ '9' } = "Wir haben Dir die AGB zugeschickt.";	
	$MessageHandler->{ '91' } = "Es trat ein Server Fehler beim versenden der ABGs auf.";	

	# gratis Account - handyanmeldung
	$MessageHandler->{ 'E5' } = "Willkommen bei www.bitjoe.de! Deine Nutzerdaten findest Du im BitJoe Menu!";		
	$MessageHandler->{ 'E4' } = "Mit Deinen Nutzerdaten kannst Du auf www.bitjoe.de/login oder vom Handy aus Dein Konto aufladen";		
	$MessageHandler->{ 'E3' } = "Lade bitte Dein Konto auf um BitJoe im vollen Funktionsumfang nutzen zu können!";		
	$MessageHandler->{ 'E2' } = "Kein Download mehr moeglich! Logge Dich bei www.bitjoe.de/login ein oder lade Dein Guthaben vom Handy aus auf!";		
	$MessageHandler->{ 'E1' } = "KEIN DOWNLOAD MEHR MOEGLICH! KONTO AUFLADEN EMPFOHLEN!";		
	$MessageHandler->{ 'E0' } = "KEIN DOWNLOAD MEHR MOEGLICH! KONTO AUFLADEN EMPFOHLEN!";		
	
	# gratis Account - normale user anmeldung
	$MessageHandler->{ 'G5' } = "Wir hoffen, dass Du viel Spass mit BitJoe haben wirst :-)";		
	$MessageHandler->{ 'G4' } = "Hallo! Bei BitJoe suchst Du in über 10 Mio. Dateien!";		
	$MessageHandler->{ 'G3' } = "Tip: Unter www.bitjoe.de/login kannst Du Dein BitJoe verwalten.";		
	$MessageHandler->{ 'G2' } = "Deine gratis Suchanfragen sind fast aufgebraucht. Lade am besten Dein Konto auf!";		
	$MessageHandler->{ 'G1' } = "Du hast noch eine gratis Suchanfrage...";		
	$MessageHandler->{ 'G0' } = "Um BitJoe weiter nutzen zu können, musst Du Dein Konto aufladen. Logge Dich bei www.BitJoe.de/login ein oder lade Dein Guthaben vom Handy aus auf.";		

	# Volumen Account Random bei <3 freien suchanfragen
	$MessageHandler->{ 'V2' } = "Du hast nur noch 2 Suchanfragen übrig, vergesse nicht Dein Konto aufzuladen!";	
	$MessageHandler->{ 'V1' } = "Du hast noch eine freie Suchanfrage… ";	
	$MessageHandler->{ 'V0' } = "Um BitJoe weiter nutzen zu können, musst Du Dein Konto aufladen. Logge Dich bei www.BitJoe.de/login ein oder lade Dein Guthaben vom Handy aus auf.";	
	
	# Volumen Account Random bei >3 freien suchanfragen
	$MessageHandler->{ 'VR4' } = "Tip: eine Flatrate gibt es bereits ab 19,95 EUR!";	
	$MessageHandler->{ 'VR3' } = "Tip: Falls BitJoe mal etwas nicht findet, reduziere die Anzahl der Suchbegriffe!";	
	$MessageHandler->{ 'VR2' } = "Wie wärs mit einer Flatrate? Einfach unter www.bitjoe.de/login einloggen und buchen!";	
	$MessageHandler->{ 'VR1' } = "Wenn Dir BitJoe gefällt, dann empfehle uns doch weiter!";	
	$MessageHandler->{ 'VR0' } = "Tip: Falls BitJoe mal etwas nicht findet, benutze doch die englische Übersetzung Deines Suchbegriffes!";	
	# $MessageHandler->{ 'V' } = "";	
	
	# Flatrate 
	$MessageHandler->{ 'F0' }	= "Um BitJoe weiter nutzen zu können, musst Du Dein Konto aufladen. Logge Dich bei www.BitJoe.de/login ein oder lade Dein Guthaben vom Handy aus auf.";
	$MessageHandler->{ 'FR1' }	= "Wenn Dir BitJoe gefällt, empfehle uns doch weiter!";	
	$MessageHandler->{ 'FR0' }	= "Tip: Falls BitJoe mal etwas nicht findet, benutze doch die englische Übersetzung deines Suchbegriffes!";	
	$MessageHandler->{ 'FR2' }	= "Tip: Falls BitJoe mal etwas nicht findet, reduziere die Anzahl der Suchbegriffe!";	


	# HandyAnmeldung UserCreate
	$MessageHandler->{ 'UC0' }	= "BETA MELDUNG: WIR HABEN DIR EINEN USER AUTOMATISCH ERSTELLT.DU KANNST IHN UNTER BENUTZERDATEN ANZEIGEN LASSEN.";
	
	# HandyAnmeldung User hat kein SuccessFull volumen mehr und bekommt nur noch fakes
	$MessageHandler->{ 'HA0' }	= "             BITTE KONTO AUFLADEN!";

	return $MessageHandler;

}; # sub Messages(){


sub MessagesEN(){
	
	my $self = shift;
	my $MessageHandler;
	
	$MessageHandler->{ '1' } = "Hint: you can upgrade your account on www.bitjoe.de/login !";			# Hallo Messages
	$MessageHandler->{ '2' } = "Your bitjoe.com version is invalid!";														# licence valid status message
	$MessageHandler->{ '3' } = "Your bitjoe.com account data is invalid! You can get the newest BitJoe Software for free on the page www.bitjoe.com .";	# licence invalid status=-1 message
	$MessageHandler->{ '31' } = "Your bitjoe.com volume pay scale is used up. You can call from your mobile phone to upgrade your pay scale or you can go to www.bitjoe.com/login and buy a new one. We suggest you to buy a BitJoe Flatrate for unlimited access!"; # licence invalid status=0 message
	$MessageHandler->{ '4' } = "ErrorCode 1001. Action has been terminated.";											# crypto key error
	$MessageHandler->{ '5' } = "The bitjoe.com Service is currently very busy, please try again in a few minutes.";		# load to high error message
	$MessageHandler->{ '6' } = "There was an error while installing your Code.";		
	$MessageHandler->{ '7' } = "Sorry, no search results.";		
	$MessageHandler->{ '8' } = "There was an error during your payment request.";		
	$MessageHandler->{ '9' } = "We send you the BitJoe Act.";	
	$MessageHandler->{ '91' } = "There was a server error while sending you the BitJoe Act.";	

	# gratis Account - handyanmeldung
	$MessageHandler->{ 'E5' } = "Welcome to www.bitjoe.com! Your account data can be found in the BitJoe Menu!";	
	$MessageHandler->{ 'E4' } = "With your account data you can upgrade your account on www.bitjoe.com or even from your mobile phone!";
	$MessageHandler->{ 'E3' } = "Please upgrade your pay scale to furthermore use all features of BitJoe. ";		
	$MessageHandler->{ 'E2' } = "No more downloading possible! Please upgrade your pay scale on www.bitjoe.com or from your mobile phone!";
	$MessageHandler->{ 'E1' } = "NO MORE DOWNLOADING POSSIBLE! WE SUGGEST TO UPGRADE YOUR PAY SCALE!";		
	$MessageHandler->{ 'E0' } = "NO MORE DOWNLOADING POSSIBLE! WE SUGGEST TO UPGRADE YOUR PAY SCALE!";		
	
	# gratis Account - normale user anmeldung
	$MessageHandler->{ 'G5' } = "We hope that you will have a lot of fun with the BitJoe Software :-)"; 
	$MessageHandler->{ 'G4' } = "Hello. BitJoe is searching for you in over 10 Million Files!";		
	$MessageHandler->{ 'G3' } = "Hint: www.bitjoe.com/login can be used to manage your BitJoe.";		
	$MessageHandler->{ 'G2' } = "your free search querys are almost used up. please buy an upgrade!";		
	$MessageHandler->{ 'G1' } = "you have one free search query left ...";		
	$MessageHandler->{ 'G0' } = "You need to upgrade your pay scale. Please upgrade your pay scale!";

	# Volumen Account Random bei <3 freien suchanfragen
	$MessageHandler->{ 'V2' } = "You only have 2 search querys left, please dont forget to upgrade your account!";	
	$MessageHandler->{ 'V1' } = "you have one free search query left ...";	
	$MessageHandler->{ 'V0' } = "If you want to use any further you must upgrade your account scale.";	
	
	# Volumen Account Random bei >3 freien suchanfragen
	$MessageHandler->{ 'VR4' } = "Tip: eine Flatrate gibt es bereits ab 19,95 EUR!";	
	$MessageHandler->{ 'VR3' } = "Tip: Falls BitJoe mal etwas nicht findet, reduziere die Anzahl der Suchbegriffe!";	
	$MessageHandler->{ 'VR2' } = "Wie wärs mit einer Flatrate? Einfach unter www.bitjoe.de/login einloggen und buchen!";	
	$MessageHandler->{ 'VR1' } = "Wenn Dir BitJoe gefällt, dann empfehle uns doch weiter!";	
	$MessageHandler->{ 'VR0' } = "Tip: Falls BitJoe mal etwas nicht findet, benutze doch die englische Übersetzung Deines Suchbegriffes!";	
	# $MessageHandler->{ 'V' } = "";	
	
	# Flatrate 
	$MessageHandler->{ 'F0' }	= "Um BitJoe weiter nutzen zu können, musst Du Dein Konto aufladen. Logge Dich bei www.BitJoe.de/login ein oder lade Dein Guthaben vom Handy aus auf.";
	$MessageHandler->{ 'FR1' }	= "Wenn Dir BitJoe gefällt, empfehle uns doch weiter!";	
	$MessageHandler->{ 'FR0' }	= "Tip: Falls BitJoe mal etwas nicht findet, benutze doch die englische Übersetzung deines Suchbegriffes!";	
	$MessageHandler->{ 'FR2' }	= "Tip: Falls BitJoe mal etwas nicht findet, reduziere die Anzahl der Suchbegriffe!";	


	# HandyAnmeldung UserCreate
	$MessageHandler->{ 'UC0' }	= "BETA MELDUNG: WIR HABEN DIR EINEN USER AUTOMATISCH ERSTELLT.DU KANNST IHN UNTER BENUTZERDATEN ANZEIGEN LASSEN.";
	
	# HandyAnmeldung User hat kein SuccessFull volumen mehr und bekommt nur noch fakes
	$MessageHandler->{ 'HA0' }	= "             BITTE KONTO AUFLADEN!";

	return $MessageHandler;

}; # sub sub MessagesEN(){


return 1;