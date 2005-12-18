//===-- SparcV8AsmPrinter.cpp - SparcV8 LLVM assembly writer --------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file was developed by the LLVM research group and is distributed under
// the University of Illinois Open Source License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to GAS-format Sparc V8 assembly language.
//
//===----------------------------------------------------------------------===//

#include "SparcV8.h"
#include "SparcV8InstrInfo.h"
#include "llvm/Constants.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Module.h"
#include "llvm/Assembly/Writer.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/Target/TargetMachine.h"
#include "llvm/Support/Mangler.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/MathExtras.h"
#include <cctype>
using namespace llvm;

namespace {
  Statistic<> EmittedInsts("asm-printer", "Number of machine instrs printed");

  struct SparcV8AsmPrinter : public AsmPrinter {
    SparcV8AsmPrinter(std::ostream &O, TargetMachine &TM) : AsmPrinter(O, TM) {
      Data16bitsDirective = "\t.half\t";
      Data32bitsDirective = "\t.word\t";
      Data64bitsDirective = "\t.xword\t";
      ZeroDirective = 0;  // no .zero or .space!
    }

    /// We name each basic block in a Function with a unique number, so
    /// that we can consistently refer to them later. This is cleared
    /// at the beginning of each call to runOnMachineFunction().
    ///
    typedef std::map<const Value *, unsigned> ValueMapTy;
    ValueMapTy NumberForBB;

    virtual const char *getPassName() const {
      return "SparcV8 Assembly Printer";
    }

    void printOperand(const MachineInstr *MI, int opNum);
    void printMemOperand(const MachineInstr *MI, int opNum);
    bool printInstruction(const MachineInstr *MI);  // autogenerated.
    bool runOnMachineFunction(MachineFunction &F);
    bool doInitialization(Module &M);
    bool doFinalization(Module &M);
  };
} // end of anonymous namespace

#include "SparcV8GenAsmWriter.inc"

/// createSparcV8CodePrinterPass - Returns a pass that prints the SparcV8
/// assembly code for a MachineFunction to the given output stream,
/// using the given target machine description.  This should work
/// regardless of whether the function is in SSA form.
///
FunctionPass *llvm::createSparcV8CodePrinterPass (std::ostream &o,
                                                  TargetMachine &tm) {
  return new SparcV8AsmPrinter(o, tm);
}

/// runOnMachineFunction - This uses the printMachineInstruction()
/// method to print assembly for each instruction.
///
bool SparcV8AsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  SetupMachineFunction(MF);

  // Print out constants referenced by the function
  EmitConstantPool(MF.getConstantPool());

  // BBNumber is used here so that a given Printer will never give two
  // BBs the same name. (If you have a better way, please let me know!)
  static unsigned BBNumber = 0;

  O << "\n\n";
  // What's my mangled name?
  CurrentFnName = Mang->getValueName(MF.getFunction());

  // Print out labels for the function.
  O << "\t.text\n";
  O << "\t.align 16\n";
  O << "\t.globl\t" << CurrentFnName << "\n";
  O << "\t.type\t" << CurrentFnName << ", #function\n";
  O << CurrentFnName << ":\n";

  // Number each basic block so that we can consistently refer to them
  // in PC-relative references.
  NumberForBB.clear();
  for (MachineFunction::const_iterator I = MF.begin(), E = MF.end();
       I != E; ++I) {
    NumberForBB[I->getBasicBlock()] = BBNumber++;
  }

  // Print out code for the function.
  for (MachineFunction::const_iterator I = MF.begin(), E = MF.end();
       I != E; ++I) {
    // Print a label for the basic block.
    O << ".LBB" << Mang->getValueName(MF.getFunction ())
      << "_" << I->getNumber () << ":\t! "
      << I->getBasicBlock ()->getName () << "\n";
    for (MachineBasicBlock::const_iterator II = I->begin(), E = I->end();
         II != E; ++II) {
      // Print the assembly for the instruction.
      O << "\t";
      printInstruction(II);
      ++EmittedInsts;
    }
  }

  // We didn't modify anything.
  return false;
}

void SparcV8AsmPrinter::printOperand(const MachineInstr *MI, int opNum) {
  const MachineOperand &MO = MI->getOperand (opNum);
  const MRegisterInfo &RI = *TM.getRegisterInfo();
  bool CloseParen = false;
  if (MI->getOpcode() == V8::SETHIi && !MO.isRegister() && !MO.isImmediate()) {
    O << "%hi(";
    CloseParen = true;
  } else if (MI->getOpcode() ==V8::ORri &&!MO.isRegister() &&!MO.isImmediate())
  {
    O << "%lo(";
    CloseParen = true;
  }
  switch (MO.getType()) {
  case MachineOperand::MO_VirtualRegister:
    if (Value *V = MO.getVRegValueOrNull()) {
      O << "<" << V->getName() << ">";
      break;
    }
    // FALLTHROUGH
  case MachineOperand::MO_MachineRegister:
    if (MRegisterInfo::isPhysicalRegister(MO.getReg()))
      O << "%" << LowercaseString (RI.get(MO.getReg()).Name);
    else
      O << "%reg" << MO.getReg();
    break;

  case MachineOperand::MO_SignExtendedImmed:
  case MachineOperand::MO_UnextendedImmed:
    O << (int)MO.getImmedValue();
    break;
  case MachineOperand::MO_MachineBasicBlock: {
    MachineBasicBlock *MBBOp = MO.getMachineBasicBlock();
    O << ".LBB" << Mang->getValueName(MBBOp->getParent()->getFunction())
      << "_" << MBBOp->getNumber () << "\t! "
      << MBBOp->getBasicBlock ()->getName ();
    return;
  }
  case MachineOperand::MO_PCRelativeDisp:
    std::cerr << "Shouldn't use addPCDisp() when building SparcV8 MachineInstrs";
    abort ();
    return;
  case MachineOperand::MO_GlobalAddress:
    O << Mang->getValueName(MO.getGlobal());
    break;
  case MachineOperand::MO_ExternalSymbol:
    O << MO.getSymbolName();
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    O << PrivateGlobalPrefix << "CPI" << getFunctionNumber() << "_"
      << MO.getConstantPoolIndex();
    break;
  default:
    O << "<unknown operand type>"; abort (); break;
  }
  if (CloseParen) O << ")";
}

void SparcV8AsmPrinter::printMemOperand(const MachineInstr *MI, int opNum) {
  printOperand(MI, opNum);
  MachineOperand::MachineOperandType OpTy = MI->getOperand(opNum+1).getType();
  
  if ((OpTy == MachineOperand::MO_VirtualRegister ||
       OpTy == MachineOperand::MO_MachineRegister) &&
      MI->getOperand(opNum+1).getReg() == V8::G0)
    return;   // don't print "+%g0"
  if ((OpTy == MachineOperand::MO_SignExtendedImmed ||
       OpTy == MachineOperand::MO_UnextendedImmed) &&
      MI->getOperand(opNum+1).getImmedValue() == 0)
    return;   // don't print "+0"
  
  O << "+";
  if (OpTy == MachineOperand::MO_GlobalAddress ||
      OpTy == MachineOperand::MO_ConstantPoolIndex) {
    O << "%lo(";
    printOperand(MI, opNum+1);
    O << ")";
  } else {
    printOperand(MI, opNum+1);
  }
}


bool SparcV8AsmPrinter::doInitialization(Module &M) {
  Mang = new Mangler(M);
  return false; // success
}

bool SparcV8AsmPrinter::doFinalization(Module &M) {
  const TargetData &TD = TM.getTargetData();

  // Print out module-level global variables here.
  for (Module::const_global_iterator I = M.global_begin(), E = M.global_end(); I != E; ++I)
    if (I->hasInitializer()) {   // External global require no code
      O << "\n\n";
      std::string name = Mang->getValueName(I);
      Constant *C = I->getInitializer();
      unsigned Size = TD.getTypeSize(C->getType());
      unsigned Align = TD.getTypeAlignment(C->getType());

      if (C->isNullValue() &&
          (I->hasLinkOnceLinkage() || I->hasInternalLinkage() ||
           I->hasWeakLinkage() /* FIXME: Verify correct */)) {
        SwitchSection(".data", I);
        if (I->hasInternalLinkage())
          O << "\t.local " << name << "\n";

        O << "\t.comm " << name << "," << TD.getTypeSize(C->getType())
          << "," << (unsigned)TD.getTypeAlignment(C->getType());
        O << "\t\t! ";
        WriteAsOperand(O, I, true, true, &M);
        O << "\n";
      } else {
        switch (I->getLinkage()) {
        case GlobalValue::LinkOnceLinkage:
        case GlobalValue::WeakLinkage:   // FIXME: Verify correct for weak.
          // Nonnull linkonce -> weak
          O << "\t.weak " << name << "\n";
          SwitchSection("", I);
          O << "\t.section\t\".llvm.linkonce.d." << name
            << "\",\"aw\",@progbits\n";
          break;

        case GlobalValue::AppendingLinkage:
          // FIXME: appending linkage variables should go into a section of
          // their name or something.  For now, just emit them as external.
        case GlobalValue::ExternalLinkage:
          // If external or appending, declare as a global symbol
          O << "\t.globl " << name << "\n";
          // FALL THROUGH
        case GlobalValue::InternalLinkage:
          if (C->isNullValue())
            SwitchSection(".bss", I);
          else
            SwitchSection(".data", I);
          break;
        case GlobalValue::GhostLinkage:
          std::cerr << "Should not have any unmaterialized functions!\n";
          abort();
        }

        O << "\t.align " << Align << "\n";
        O << "\t.type " << name << ",#object\n";
        O << "\t.size " << name << "," << Size << "\n";
        O << name << ":\t\t\t\t! ";
        WriteAsOperand(O, I, true, true, &M);
        O << " = ";
        WriteAsOperand(O, C, false, false, &M);
        O << "\n";
        EmitGlobalConstant(C);
      }
    }

  AsmPrinter::doFinalization(M);
  return false; // success
}
