#pragma once

#include <iostream>
#include <cstring>
#include <cstdint>
#include <memory>
#include <stdexcept>

class Vector {
public:
    enum class BitWidth : int { 
        W8 = 8,   // 16个8位数
        W16 = 16, // 8个16位数
        W32 = 32  // 4个32位数
    };

    Vector(BitWidth bw);
    void mul(int scalar);
    void add(int scalar);
    void add(const Vector& other);
    void rst();
    void load(const void* addr);
    void store(void* addr) const; 
    int sum() const;
    void print() const;

private:
    BitWidth bit_width;
    size_t count;
    std::unique_ptr<uint8_t[]> data;

    template <typename F>
    void apply_operation(F&& f) const;

    template <typename T, typename F>
    void operate(F&& f) const;

    template <typename F>
    void apply_pair_operation(const Vector& other, F&& f);

    template <typename T, typename F>
    void pair_operate(const Vector& other, F&& f);
};

template <typename F>
inline void Vector::apply_operation(F&& f) const {
    switch(bit_width) {
        case BitWidth::W8:  operate<int8_t>(f);  break;
        case BitWidth::W16: operate<int16_t>(f); break;
        case BitWidth::W32: operate<int32_t>(f); break;
    }
}

template <typename T, typename F>
inline void Vector::operate(F&& f) const {
    T* elements = reinterpret_cast<T*>(data.get());
    for(size_t i = 0; i < count; ++i) { f(elements[i]); }
}

template <typename F>
inline void Vector::apply_pair_operation(const Vector& other, F&& f) {
    switch(bit_width) {
        case BitWidth::W8:  pair_operate<int8_t>(other, f);  break;
        case BitWidth::W16: pair_operate<int16_t>(other, f); break;
        case BitWidth::W32: pair_operate<int32_t>(other, f); break;
    }
}

template <typename T, typename F>
inline void Vector::pair_operate(const Vector& other, F&& f) {
    T* a = reinterpret_cast<T*>(data.get());
    const T* b = reinterpret_cast<const T*>(other.data.get());
    for(size_t i = 0; i < count; ++i) { f(a[i], b[i]); }
}
