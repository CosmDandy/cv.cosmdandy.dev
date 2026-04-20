%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Developer CV — ATS-friendly single-column variant
% LaTeX Class
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{developercv-ats}[2026/04/22 Developer CV ATS class v1.0]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{extarticle}}
\ProcessOptions\relax

\LoadClass{extarticle}

\setlength{\parindent}{0mm}

\usepackage[hidelinks]{hyperref}

\pagestyle{empty}

\usepackage{moresize}
\usepackage{enumitem}

\usepackage{geometry}

\geometry{
	paper=a4paper,
	top=1.2cm,
	bottom=1.2cm,
	left=1.5cm,
	right=1.5cm,
	headheight=0.75cm,
	footskip=1cm,
	headsep=0.5cm,
}

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

\def\Vhrulefill{\leavevmode\leaders\hrule height 0.7ex depth \dimexpr0.4pt-0.7ex\hfill\kern0pt}

\newcommand{\cvsect}[1]{%
	\vspace{\baselineskip}
	\textcolor{black}{ \MakeUppercase{\textbf{#1}}} \hspace{4pt} \Vhrulefill \\%
}

\usepackage{longtable}
\usepackage{array}
\usepackage{colortbl}
\setlength{\LTpre}{0pt}
\setlength{\LTpost}{0pt}

\setlength{\tabcolsep}{0pt}

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

\newcommand{\slashsep}{\hspace{3mm}/\hspace{3mm}}
