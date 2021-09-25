#!/usr/bin/perl

# timestamp.pl
# 
# Copyright (c) 2020 Yoshihiro Hokazono
# 
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php


use 5.10.0;
use utf8;
use Time::Local;
use Getopt::Long qw(:config no_ignore_case);

use strict;
use warnings;

my $under_sec_part_digit = 9;
my $year_threshold = 2030;
my $check = 0;
my $use_utc = 0;
my $template;
my $template_with_under_sec;

my $HELP = <<"EOS"
Usage: timestamp [OPTION] [FILE]...
Convert all UNIX timestamps in text to human-readable string ad hoc.

With no FILE, or when FILE is -, read standard input.

  -c, --check       Show what conversion happens

  -q, --quote       Quote output string
  -i, --iso         Use ISO 8601 format
  -u, --utc         Use UTC Time Zone (By default local time is used)

  -m, --milli       Use milli precision
  -M, --Micro       Use micro precision
  -n, --nano        Use nano precision

  -h, --help        Display this help and exit

This program uses ad hoc method to find UNIX timestamp.
We highly recommend that you should check the conversion first with -c option.
EOS
;


sub proc_options {
    my $milli = 0;
    my $micro = 0;
    my $nano = 0;
    my $quote = 0;
    my $iso = 0;
    my $help = 0;
    GetOptions(
        "milli" => \$milli,
        "Micro" => \$micro,
        "nano" => \$nano,
        "utc" => \$use_utc,
        "iso" => \$iso,
        "quote" => \$quote,
        "check" => \$check,
        "help" => \$help
    );
    if ($help) {
        print $HELP;
        exit;
    }
    if ($nano) {
        $under_sec_part_digit = 9;
    } elsif ($micro) {
        $under_sec_part_digit = 6;
    } elsif ($milli) {
        $under_sec_part_digit = 3;
    } else {
        $under_sec_part_digit = 0;
    }
    if ($iso) {
        if ($use_utc) {
            $template = "%d-%02d-%02dT%02d:%02d:%02dZ";
            $template_with_under_sec = "%d-%02d-%02dT%02d:%02d:%02d.%sZ";
        } else {
            @t = localtime(time);
            $tz_offset = timegm(@t) - timelocal(@t);
            my $sign = "+";
            if ($tz_offset < 0) {
                $sign = "-";
                $tz_offset = -$tz_offset;
            }
            $tz_offset_hour = int($tz_offset / 3600);
            $tz_offset_min = int($tz_offset / 60) % 60;
            $tz_offset_str = sprintf "%s%02d:%02d", $sign, $tz_offset_hour, $tz_offset_min;
            $template = "%d-%02d-%02dT%02d:%02d:%02d" . $tz_offset_str;
            $template_with_under_sec = "%d-%02d-%02dT%02d:%02d:%02d.%s" . $tz_offset_str;
        }
    } else {
        $template = "%d-%02d-%02d %02d:%02d:%02d";
        $template_with_under_sec = "%d-%02d-%02d %02d:%02d:%02d.%s";
    }
    if ($quote) {
        $template = "\"" . $template . "\"";
        $template_with_under_sec = "\"" . $template_with_under_sec . "\"";
    }
    if ($check) {
        $template = "\e[31m%s => " . $template . "\e[0m";
        $template_with_under_sec = "\e[31m%s => " . $template_with_under_sec . "\e[0m";
    }
}


sub format_str {
    $_ = shift;
    my $sec_part = substr($_, 0, 10);
    my $under_sec_part = 
        index($_, ".") < 0 ? substr($_, 10) : substr($_, 11);
    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
        $use_utc ? gmtime $sec_part : localtime $sec_part;
    $year += 1900;
    return $_ if ($year > $year_threshold);
    $mon += 1;

    if ($under_sec_part_digit <= 0) {
        if ($check) {
            return sprintf $template, $_, $year, $mon, $mday, $hour, $min, $sec;
        } else {
            return sprintf $template, $year, $mon, $mday, $hour, $min, $sec;
        }
    } else {
        $pad = $under_sec_part_digit - length($under_sec_part);
        $under_sec_part .= "0" x $pad;
        $under_sec_part = substr($under_sec_part, 0, $under_sec_part_digit);
        if ($check) {
            return sprintf $template_with_under_sec, $_, $year, $mon, $mday, $hour, $min, $sec, $under_sec_part;
        } else {
            return sprintf $template_with_under_sec, $year, $mon, $mday, $hour, $min, $sec, $under_sec_part;
        }
    }
}

proc_options;

while (<>) {
    chomp;
    s/\b(\d{10}(?:\.\d+|\d{9}\b|\d{6}\b|\d{3}\b|\b))/format_str $1/ge;
} continue {
    say;
}
