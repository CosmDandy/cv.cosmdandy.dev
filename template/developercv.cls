%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Developer CV
% LaTeX Class
% Version 2.0 (12/10/23)
%
% This class originates from:
% http://www.LaTeXTemplates.com
%
% Authors:
% Omar Roldan
% Based on a template by  Jan Vorisek (jan@vorisek.me)
% Based on a template by Jan Küster (info@jankuester.com)
% Modified for LaTeX Templates by Vel (vel@LaTeXTemplates.com)
%
% License:
% The MIT License (see included LICENSE file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------------------
%	CLASS CONFIGURATION
%----------------------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{developercv}[2023/10/12 Developer CV class v2.0]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}} % Pass through any options to the base class
\ProcessOptions\relax % Process given options

\LoadClass{extarticle} % Load the base class

%----------------------------------------------------------------------------------------
%	PACKAGES AND OTHER DOCUMENT CONFIGURATIONS
%----------------------------------------------------------------------------------------

\setlength{\parindent}{0mm} % Suppress paragraph indentation

\usepackage[hidelinks]{hyperref} % Required for links but hide the default boxes around links

\pagestyle{empty} % No headers or footers

\usepackage{moresize} % Provides more font size commands (\HUGE and \ssmall)
\usepackage{enumitem}
%----------------------------------------------------------------------------------------
%	PAGE LAYOUT
%----------------------------------------------------------------------------------------

\usepackage{geometry} % Required for adjusting page dimensions and margins

\geometry{
	paper=a4paper,
	top=1cm,
	bottom=1cm,
	left=1cm,
	right=1cm,
	headheight=0.75cm,
	footskip=1cm,
	headsep=0.5cm,
	%showframe,
}

%----------------------------------------------------------------------------------------
%	FONTS
%----------------------------------------------------------------------------------------

\usepackage{fontspec}
\usepackage[english,russian]{babel}

\setmainfont{Inter}[
  UprightFont = *-Light,
  BoldFont = *-Medium,
  ItalicFont = *-LightItalic,
  BoldItalicFont = *-MediumItalic,
]
\setsansfont{Inter}[
  UprightFont = *-Light,
  BoldFont = *-Medium,
  ItalicFont = *-LightItalic,
  BoldItalicFont = *-MediumItalic,
]

\renewcommand*\familydefault{\sfdefault}

%------------------------------------------------

\usepackage{fontawesome5} % Required for FontAwesome 5 icons (includes Telegram, etc.)

% Command to output an icon with text to the right
\newcommand{\icon}[3]{% The first parameter is the FontAwesome icon name, the second is the box size and the third is the text
	\vcenteredhbox{\colorbox{white}{\makebox(#2, #2){\textcolor{black}{\Large\csname fa#1\endcsname}}}}% Icon and box
	\hspace{0.1cm}% Whitespace
	\vcenteredhbox{\textcolor{black}{#3}}% Text
}

%----------------------------------------------------------------------------------------
%	GRAPHICS DEFINITIONS
%----------------------------------------------------------------------------------------

\usepackage{tikz} % Required for creating the plots
\usetikzlibrary{shapes, backgrounds}
\tikzset{x=1cm, y=1cm} % Default tikz units

% Command to vertically centre adjacent content
\newcommand{\vcenteredhbox}[1]{% The only parameter is for the content to centre
	\begingroup%
		\setbox0=\hbox{#1}\parbox{\wd0}{\box0}%
	\endgroup%
}

%----------------------------------------------------------------------------------------
%	CUSTOM SECTIONS
%----------------------------------------------------------------------------------------
\def\Vhrulefill{\leavevmode\leaders\hrule height 0.7ex depth \dimexpr0.4pt-0.7ex\hfill\kern0pt}

% Command to output section title headings
\newcommand{\cvsect}[1]{% The only parameter is the section text
	\vspace{\baselineskip} % Whitespace before the section title
	\textcolor{black}{ \MakeUppercase{\textbf{#1}}} \hspace{4pt} \Vhrulefill \\% Section title
}

%----------------------------------------------------------------------------------------
%	ENTRY LIST
%----------------------------------------------------------------------------------------

\usepackage{longtable} % Required for tables that span multiple pages
\usepackage{array} % Required for custom column types
\usepackage{colortbl} % Required for colored rules in tables
\setlength{\LTpre}{0pt} % Remove default whitespace before longtable
\setlength{\LTpost}{0pt} % Remove default whitespace after longtable

\setlength{\tabcolsep}{0pt} % No spacing between table columns

% Environment to hold a new list of entries
\newenvironment{entrylist}{
	\begin{longtable}[H]{l @{\hspace{10pt}} l}
}{
	\end{longtable}
}

\newcommand{\entry}[4]{%
	\parbox[t]{0.17\textwidth}{%
	   \small #1
	}%
	&\parbox[t]{0.81\textwidth}{%
		\textbf{#2}%
		\hfill%
		{\footnotesize \textbf{\textcolor{black}{#3}}}\\[1pt]%
		#4
	}\\\\}

\newcommand{\entrywork}[4]{%
	\parbox[t]{0.17\textwidth}{%
	   \small #1
	}%
	&\parbox[t]{0.81\textwidth}{%
		\textbf{#2}%
		\hfill%
		{\footnotesize \textbf{\textcolor{black}{#3}}}\\%
		#4
	}\\\\}

% Timeline: place a named coordinate in the date column
\newcommand{\timelinemark}[1]{%
	\hfill\tikz[remember picture, baseline=-0.5ex] \coordinate (#1);%
}

% Timeline: draw a line segment with gap between two coordinates
\newcommand{\timelinesegment}[2]{%
	\smash{\tikz[remember picture, overlay]{%
		\draw[line width=1.5pt, color=black!30]
			([xshift=-8pt, yshift=-6pt]#1) -- ([xshift=-8pt, yshift=6pt]#2);%
	}}%
}

% Timeline: draw a dot at a coordinate
\newcommand{\timelinedot}[1]{%
	\smash{\tikz[remember picture, overlay]{%
		\fill[black!40] ([xshift=-8pt]#1) circle (2.5pt);%
	}}%
}

% Command to output a separator slash between lists, e.g. '  /  '
\newcommand{\slashsep}{\hspace{3mm}/\hspace{3mm}}
