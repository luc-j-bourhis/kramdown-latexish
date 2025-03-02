# Kramdown::Latexish

It is an extension of the Kramdown syntax taylored for mathematical articles. Its general philosophy is to imitate LaTeX as much as possible without being too verbose. This document describes the new syntactical elements added to Kramdown. We refer the reader to the documentation of the API for guidance to use it.

## New syntax

An important point is that each document has a language associated to it, and several concepts are then accordingly localised. We currently support English and French only but the code could easily be extended to support many more. We will provide HTML conversion as illustrations as it will be the main target but there is no conceptual reason the other converters should not work.

### Equations

The only difference with vanilla Kramdown is that span math can be marked with single dollars, as it is customary in LaTeX, in addition to the double dollars used in vanilla Kramdown.

```
The identity $e^{i\pi} + 1 = 0$ is attributed to Euler.
```

will eventually produce the HTML

```
<p>The identity \(e^{i\pi} + 1 = 0\) is attributed to Euler.</p>
```

and so will

```
The identity is $$e^{i\pi} + 1 = 0$$ it attributed to Euler.
```

As in vanilla Kramdown, one shall write block equations as

```
The identity

$$e^{i\pi} + 1 = 0$$

is attributed to Euler.
```

exactly as in vanilla Kramdown. This produces

```
<p>The identity</p>

\[ e^{i\pi} + 1 = 0 \]

<p>is attributed to Euler.</p>
```

Typically, one shall then rely on MathJax to render `\(…\)` and `\[…\]`.

### Theorem-like environments

Theorem-like environments look as follow.

```
We shall first prove the following.

Lemma (Eigenspace orthogonality)

For any symmetric matrix $M$, and any two eigenvalues $\lambda \ne \lambda'$, the eigenvectors for $\lambda$ are orthogonal to the eigenvectors for $\lambda'$.

\Lemma

It can then be used to prove the following.

Theorem (Diagonalisation)

Any symmetric matrix can be diagonalised in an orthogonal basis.

\Theorem
```
We have defined two such environments in this example, of two different types. We support the following types: :definition, :property, :lemma, :theorem, and :corollary, where we use a colon prefix to distinguish them from the English words. Each environment type is introduced by a capitalised name. In English, the types without the colon. In French: définition, propriété, lemme, théorème, et corollaire.

Such an environment starts with a new paragraph, whose first word is one of those environment names. There cannot be any space at the beginning of that paragraph. A title for the environment may then appear between parentheses. Then, after perhaps some spaces, the paragraph must end: the next paragraph will start the body of the theorem.

That body then extends until the environment name prefixed by a backlash. That end tag must be alone in its own paragraph, without any leading spaces but trailing spaces are allowed.

The body of the environment is parsed as any other part of the document whereas the title line is encased in a header, and the whole environment in a section with class "theorem-like". Thus the example above renders as

```
<p>We shall first prove the following.</p>

<section class="theorem-like">
<h5><strong>Lemma 1</strong> (Eigenspace orthogonality)</h5>

<p>For any symmetric matrix $M$, and any two eigenvalues $\lambda \ne \lambda'$, the eigenvectors for $\lambda$ are orthogonal to the eigenvectors for $\lambda'$.</p>

</section>

<p>It can then be used to prove the following.</p>

<section class="theorem-like">
<h5><strong>Theorem 1</strong> (Diagonalisation)</h5>

<p>Any symmetric matrix can be diagonalised in an orthogonal basis.</p>

</section>
```
A few remarks are in order:
- the level of the header is user-customisable (h5 is the default)
- as shown, each environment is numbered, with a different numbering for each type

The first line of the environment can receives Kramdown IAL's in the usual manner
```
{: #Euler}
Theorem

\Theorem
```
or
```
Theorem
{: #Euler}

\Theorem
```

Either of those would result in the `<section>` tag to be be given the identifier `Euler`.

### Automatically numbered section headers

Sections as well as all theorem-like environment are automatically numbered.

Section numbers follow the pattern x.y.z, for example

```
## One

### One

### Two

## Two
```

would result in

```
<h2>1 One</h2>

<h3>1.1 One</h3>

<h3>1.2 Two</h3>

<h2>2 Two<h2>
```

A single number is used for theorem-like environment, each type being numbered separately. For example,

```
Theorem (Taylor-Young)

\Theorem

Lemma (Rolle)

\Lemma

Theorem (Taylor-Cauchy)

\Theorem
```

would result in `Theorem 1 (Taylor-Young)`, `Theorem 2 (Taylor-Cauchy)`, and `Lemma 1 (Rolle)`.

### Referencing sections or theorem-like environments

If a section or a theorem-like environment was given an identifier `xxx`, either with an IAL `{: ... #xxx ...}` or for a section the special syntax `{#xxx}`, then the syntax
`[cref:xxx]` will produce the like of

```
section <a href="#xxx" title="Section 5">5</a>
```

whereas `[Cref:xxx]` (note the capital letter) will then produce

```
Section <a href="#xxx" title="Section 5">5</a>
```

i.e. a link to that identifier, with the number as content, and with the type of the element referred to.

LaTeX users will recognise the cleveref package, from which we also borrow multiple references: `[cref:one,two,three,four,five,six]` will produce

```
sections&nbsp;<a href="#two" title="Section 1.1">1.1</a>, <a href="#four" title="Section 3.2">3.2</a>, and&nbsp;<a href="#six" title="Section 1.8">1.8</a>, theorems&nbsp;<a href="#one" title="Theorem 1">1</a> and&nbsp;<a href="#five" title="Theorem 3">3</a>, and corollary&nbsp;<a href="#three" title="Corollary 5">5</a>
```

if those id's had been assigned to the corresponding sections and environments. As can be seen, the spaces between "sections", "theorems", "corollary" and the following anchor are actually non-breakable (`&nbsp;`), and so are the spaces following the word "and".

The words used to introduce the anchors are of course localised in the document language. As for equations, they are typeset as `eqn \eqref{key}` and `eqns \eqref{key} and \eqref{other_key}`, with non-breakable spaces before the `\eqref`. This way, Mathjax will be able to put the numbers for the equations which were marked with `\label{key}`.

### Bibliography and citations

Bibliographic entries come from a file or a string in BibTeX format, in which each entry must have a key. A reference section will be added at the end of the document, introduced by a level-2 header titled "References" in English and "Références" in French. It will contain only those entries that are cited in the document, thus skipping the entries in the BibTeX input which do not appear in the main body of the document.

The user can choose the style used to format it, among those supported by CSL. A list can be found [here](https://github.com/citation-style-language/styles). Each entry will be wrapped in a paragraph with a class "bibliography-item" to make it easy to customize styling. With the APA style, it would for example looks like this
```
<p class="bibliography-item" id="Einstein1905"> Einstein, A. (1905). Zur Elektrodynamik bewegter Körper. <i>Annalen Der Physik</i>, <i>17</i>, 891.</p>
```

Two types of citations can be made, a parenthical one,
```
[citep: Einstein1905]
```
will give
```
<a href="#Einstein1905">(Einstein, 1905)</a>
```
and a textual one,
```
[citet: Einstein1905]
```
will give
```
<a href="#Einstein:SR">Einstein (1905)</a>
```
Thus the citation is always typeset with the surname and the year of publication, using the notation from the natbib LaTeX package

When there are several authors, they all appear, for example
```
<p><a href="#Lammerzahl_etal">(Lämmerzahl, Braxmaier, Dittus, Müller, Peters, and Schiller, 2002)</a></p>
```
except if the BibTeX key is preceded by a star, i.e.
```
[citet: *Lammerzahl_etal]
```
will give
```
<a href="#Lammerzahl_etal">Lämmerzahl et al (1975)</a>
```
instead.

Finaly, several citations can be made in one instruction
```
[citep: citeX, citeY, citeZ]
```
resulting in those citations being combined in a conjunction with commans and a final word "and", in the same manner as for the references to sections, theorem-like environments and equations described in the previous section.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'kramdown-latexish'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kramdown-latexish

## Usage

Given a string `source` and a hash `options` (c.f. [Kramdown documentation](https://kramdown.gettalong.org/rdoc/Kramdown/Options.html)), the following snippet will convert the extended Kramdown in that string into HTML

```ruby
require 'kramdown/latexish'

options = Kramdown::Latexish::taylor_options(options)
doc = Kramdown::Document.initialize(source, options)
converted = doc.html
```

The rationales for this design is explained in the documentation for method `Kramdown::Latexish::taylor_options`.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/luc-j-bourhis/kramdown-latexish.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
