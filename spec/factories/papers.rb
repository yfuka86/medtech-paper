# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :paper do
    pubmed_id 10592235
    journal_id 1
    received_date "2015-01-23"
    accepted_date "2015-02-23"
    published_date "2015-03-23"
    title "The Protein Data Bank"
    volume 1
    issue 20
    pages "111-122"
    abstract "The Protein Data Bank (PDB; http://www.rcsb.org/pdb/ ) is the single worldwide archive of structural data of biological macromolecules. This paper describes the goals of the PDB, the systems in place for data deposition and access, how to obtain further information, and near-term plans for the future development of the resource."
    rawdata ""
  end
end
