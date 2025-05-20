// See LICENSE.Berkeley for license details.
// See LICENSE.SiFive for license details.

package freechips.rocketchip.meek

import chisel3._
import chisel3.util.log2Ceil
import freechips.rocketchip.util._
import freechips.rocketchip.util.property

//event 
/*
(Bool,Bool,UInt) 分别为是否触发，是否是vec，增量，注意这里vec只能和vec相加，否则未定义行为
*/
class EventSet(val gate: (UInt, UInt) => Bool, val events: Seq[(String, () => (Bool,Bool,UInt))]) {
  def size = events.size
  val hits    = WireDefault(VecInit(Seq.fill(size)(false.B)))
  val is_vec  = WireDefault(VecInit(Seq.fill(size)(false.B)))
  val cnt     = WireDefault(VecInit(Seq.fill(size)(0.U(64.W))))


  def check(mask: UInt) = {
    events.zipWithIndex.foreach { case ((_, eventFunc), i) =>
      val (hit, isVec, count) = eventFunc()
      hits(i) := hit
      is_vec(i) := isVec
      cnt(i) := count
    }
    val vec_en = (hits.asUInt&is_vec.asUInt&mask).orR

    val mask_cnt = ((hits.asUInt&is_vec.asUInt&mask).asBools zip cnt).map{case(en,inc)=>
      Mux(en,inc,0.U)
    }
    (Mux(vec_en,mask_cnt.reduce(_+_),gate(mask, hits.asUInt).asUInt))
  }

  def dump(): Unit = {
    for (((name, _), i) <- events.zipWithIndex)
      when (check(1.U << i)>0.U) { printf(s"Event $name\n") }
  }
  def withCovers: Unit = {
    events.zipWithIndex.foreach {
      case ((name, func), i) => 
        val (hit, _, _) = func()
        property.cover(gate((1.U << i), (hit << i)), name)
    }
  }
}

class EventSets(val eventSets: Seq[EventSet]) {
  def maskEventSelector(eventSel: UInt): UInt = {
    // allow full associativity between counters and event sets (for now?)
    val setMask = (BigInt(1) << eventSetIdBits) - 1
    val maskMask = ((BigInt(1) << eventSets.map(_.size).max) - 1) << maxEventSetIdBits
    eventSel & (setMask | maskMask).U
  }

  private def decode(counter: UInt): (UInt, UInt) = {
    require(eventSets.size <= (1 << maxEventSetIdBits))
    require(eventSetIdBits > 0)
    (counter(eventSetIdBits-1, 0), counter >> maxEventSetIdBits)
  }

  def evaluate(eventSel: UInt): UInt = {
    val (set, mask) = decode(eventSel)
    val sets = for (e <- eventSets) yield {
      require(e.hits.getWidth <= mask.getWidth, s"too many events ${e.hits.getWidth} wider than mask ${mask.getWidth}")
      e check mask
    }
    sets(set)
  }

  def cover() = eventSets.foreach { _.withCovers }

  private def eventSetIdBits = log2Ceil(eventSets.size)
  private def maxEventSetIdBits = 8

  require(eventSetIdBits <= maxEventSetIdBits)
}
class SuperscalarEventSets(val eventSets: Seq[(Seq[EventSet], (UInt, UInt) => UInt)]) {
  def evaluate(eventSel: UInt): UInt = {
    val (set, mask) = decode(eventSel)
    val sets = for ((sets, reducer) <- eventSets) yield {
      sets.map { set =>
        require(set.hits.getWidth <= mask.getWidth, s"too many events ${set.hits.getWidth} wider than mask ${mask.getWidth}")
        set.check(mask)
      }.reduce(reducer)
    }
    val zeroPadded = sets.padTo(1 << eventSetIdBits, 0.U)
    zeroPadded(set)
  }

  def toScalarEventSets: EventSets = new EventSets(eventSets.map(_._1.head))

  def cover(): Unit = { eventSets.foreach(_._1.foreach(_.withCovers)) }

  private def decode(counter: UInt): (UInt, UInt) = {
    require(eventSets.size <= (1 << maxEventSetIdBits))
    require(eventSetIdBits > 0)
    (counter(eventSetIdBits-1, 0), counter >> maxEventSetIdBits)
  }

  private def eventSetIdBits = log2Ceil(eventSets.size)
  private def maxEventSetIdBits = 8

  require(eventSets.forall(s => s._1.forall(_.size == s._1.head.size)))
  require(eventSetIdBits <= maxEventSetIdBits)
}
