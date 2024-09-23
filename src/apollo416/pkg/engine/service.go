package engine

import (
	"github.com/hyperjumptech/grule-rule-engine/ast"
	"github.com/hyperjumptech/grule-rule-engine/builder"
	"github.com/hyperjumptech/grule-rule-engine/engine"
	"github.com/hyperjumptech/grule-rule-engine/pkg"
)

type Decision struct {
	Age      int
	Approved bool
}

type Service struct {
	engine        *engine.GruleEngine
	knowledgeBase *ast.KnowledgeBase
}

func NewService() *Service {
	lib := ast.NewKnowledgeLibrary()
	rb := builder.NewRuleBuilder(lib)

	err := rb.BuildRuleFromResource("Test", "0.0.1", pkg.NewFileResource("decision.grl"))
	if err != nil {
		panic(err)
	}

	kb, err := lib.NewKnowledgeBaseInstance("Test", "0.0.1")
	if err != nil {
		panic(err)
	}

	eng := &engine.GruleEngine{MaxCycle: 1}
	return &Service{
		engine:        eng,
		knowledgeBase: kb,
	}
}

func (s *Service) Execute(decision *Decision) error {
	dataContext := ast.NewDataContext()
	err := dataContext.Add("Decision", decision)
	if err != nil {
		panic(err)
	}
	return s.engine.Execute(dataContext, s.knowledgeBase)
}
