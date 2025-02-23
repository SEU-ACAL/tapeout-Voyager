
// #include "include/v_isa.h"

// #include <iostream>
// #include <cstring>
// #include <cstdint>
// #include <memory>
// #include <stdexcept>

// class Vector {
// public:
//     enum class BitWidth : int { 
//         W8 = 8,   // 16个8位数
//         W16 = 16, // 8个16位数
//         W32 = 32  // 4个32位数
//     };

//     // 配置指令
//     Vector(BitWidth bw) : bit_width(bw) {
//         count = (16 * 8) / static_cast<int>(bit_width);
//         data = std::make_unique<uint8_t[]>(16);
//         memset(data.get(), 0, 16);
//     }

//     // 标量乘法
//     void multiply(int scalar) {
//         apply_operation([scalar](auto& val) { val *= scalar; });
//     }

//     // 标量加法
//     void add(int scalar) {
//         apply_operation([scalar](auto& val) { val += scalar; });
//     }

//     // 向量求和
//     int sum() const {
//         int total = 0;
//         apply_operation([&total](auto val) { total += val; });
//         return total;
//     }

//     // 向量相加（结果存在当前向量）
//     void add(const Vector& other) {
//         if (bit_width != other.bit_width) {
//             throw std::invalid_argument("Vector bit width mismatch");
//         }
//         auto op = [](auto& a, auto b) { a += b; };
//         apply_pair_operation(other, op);
//     }

//     // 打印向量内容
//     void print() const {
//         std::cout << "[";
//         apply_operation([](auto val) { std::cout << +val << " "; });
//         std::cout << "]\n";
//     }

// private:
//     BitWidth bit_width;
//     size_t count;
//     std::unique_ptr<uint8_t[]> data; // 始终占用16字节

//     // 通用操作模板
//     template <typename F>
//     void apply_operation(F&& f) const {
//         switch(bit_width) {
//             case BitWidth::W8:  operate<int8_t>(f);  break;
//             case BitWidth::W16: operate<int16_t>(f); break;
//             case BitWidth::W32: operate<int32_t>(f); break;
//         }
//     }

//     template <typename T, typename F>
//     void operate(F&& f) const {
//         T* elements = reinterpret_cast<T*>(data.get());
//         for(size_t i = 0; i < count; ++i) { f(elements[i]); }
//     }

//     // 向量对操作模板
//     template <typename F>
//     void apply_pair_operation(const Vector& other, F&& f) {
//         switch(bit_width) {
//             case BitWidth::W8:  pair_operate<int8_t>(other, f);  break;
//             case BitWidth::W16: pair_operate<int16_t>(other, f); break;
//             case BitWidth::W32: pair_operate<int32_t>(other, f); break;
//         }
//     }
//     // f(a[i], b[i]);
//     template <typename T, typename F>
//     void pair_operate(const Vector& other, F&& f) {
//         T* a = reinterpret_cast<T*>(data.get());
//         const T* b = reinterpret_cast<const T*>(other.data.get());
//         for(size_t i = 0; i < count; ++i) { f(a[i], b[i]); }
//     }
// };

// int main() {
//     try {
//         Vector vec_int8(Vector::BitWidth::W8);  // 16个int8
//         Vector vec_int32(Vector::BitWidth::W32); // 4个int32
//         // 所有元素加5
//         vec_int8.add(5);       
//         vec_int8.print();
//         // 所有元素乘2
//         vec_int8.multiply(2);  
//         vec_int8.print();
//         // 所有元素加10
//         vec_int32.add(10);     
//         vec_int32.print();
//         // 元素自加
//         vec_int32.add(vec_int32);  
//         vec_int32.print();
//         std::cout << "Vec8_Sum: " << vec_int8.sum() << "\n";   // 输出总和
//         std::cout << "Vec32_Sum: " << vec_int32.sum() << "\n";
//     } catch (const std::exception& e) {
//         std::cerr << "Error: " << e.what() << "\n";
//     }
//     return 0;
// }

#include "include/v_isa.h"

Vector::(BitWidth bw) : bit_width(bw) {
    count = (16 * 8) / static_cast<int>(bit_width);
    data = std::make_unique<uint8_t[]>(16);
    memset(data.get(), 0, 16);
}

void Vector::multiply(int scalar) {
    apply_operation([scalar](auto& val) { val *= scalar; });
}

void Vector::add(int scalar) {
    apply_operation([scalar](auto& val) { val += scalar; });
}

void Vector::add(const Vector& other) {
    if (bit_width != other.bit_width) {
        throw std::invalid_argument("Vector bit width mismatch");
    }
    auto op = [](auto& a, auto b) { a += b; };
    apply_pair_operation(other, op);
}

int Vector::sum() const {
    int total = 0;
    apply_operation([&total](auto val) { total += val; });
    return total;
}

void Vector::print() const {
    std::cout << "[";
    apply_operation([](auto val) { std::cout << +val << " "; });
    std::cout << "]\n";
}
